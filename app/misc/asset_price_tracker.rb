# Keeps track of asset prices.
# Two layers of caching here:
# 1. Cached prices to avoid requests to S3 (stored in memcachier, persists until rewritten).
#    This is in place where we use Rails.cache.
# 2. Per-request caches to avoid calling cache/rates more than once.
#    This is in place when we use instance variables.
class AssetPriceTracker
  def self.populate_data_sets(dates, assets = Asset.assets_to_track)
    ActiveRecord::Base.with_advisory_lock(LockKeys.track_asset_prices) do
      assets.each do |asset|
        DataSet.new(asset).populate(dates)
      end
    end
  end

  class Asset
    class InvalidTypeError < StandardError; end

    attr_accessor :type, :name

    def initialize(type, name)
      self.type = type
      self.name = name
    end

    def self.valid_types
      [:currency, :stock]
    end

    def valid?
      case type
      when :currency
        self.class.currencies_to_track.map(&:name).include?(name)
      when :stock
        result = StockQuote::Stock.quote(name)

        if result.instance_of?(StockQuote::NoDataForStockError)
          false
        else
          !result.last_trade_price_only.nil?
        end
      else
        raise InvalidTypeError, type
      end
    rescue StockQuote::NoDataForStockError, InvalidTypeError
      false
    end

    def self.unseeded_assets
      assets_to_seed = assets_to_track.select do |asset|
        begin
          DataSet.new(asset).fetch_for_date(1.year.ago)
          false
        rescue DataSet::InsufficientDataError
          true
        end
      end
    end

    def self.assets_to_track
      currencies_to_track + stocks_to_track
    end

    def self.currencies_to_track
      ["USD", "JPY", "BGN", "CZK", "DKK", "GBP", "HUF", "PLN", "RON", "SEK", "CHF", "NOK", "HRK", "RUB", "TRY", "AUD", "BRL", "CAD", "CNY", "HKD", "IDR", "ILS", "INR", "KRW", "MXN", "MYR", "NZD", "PHP", "SGD", "THB", "ZAR"].map do |currency|
        Asset.new(:currency, currency)
      end
    end

    def self.stocks_to_track
      BalanceRecordSet.where(asset_type: :stock).distinct(:asset_name).map do |balance_record_set|
        Asset.new(:stock, balance_record_set.asset_name)
      end
    end
  end

  class ConversionRequest
    class InsufficientDataError < StandardError; end

    attr_accessor :amount, :from, :to, :date

    def initialize(amount, from, to, date)
      self.amount = amount
      self.from = from
      self.to = to
      self.date = date
    end

    def result
      from_rate = from_data_set.fetch_for_date(date)
      to_rate = to_data_set.fetch_for_date(date)

      amount_converted_to_usd = case from.type
                                when :currency
                                  amount / from_rate
                                when :stock
                                  amount * from_rate
                                else
                                  raise NotImplementedError, from.type
                                end
      amount_converted_to_final = case to.type
                                  when :currency
                                    amount_converted_to_usd * to_rate
                                  when :stock
                                    amount_converted_to_usd / to_rate
                                  else
                                    raise NotImplementedError, to.type
                                  end

      amount_converted_to_final
    rescue DataSet::InsufficientDataError
      raise InsufficientDataError
    end

    private

    def from_data_set
      DataSet.new(from)
    end

    def to_data_set
      DataSet.new(to)
    end
  end

  # Caches data unless re-populated or bust_instance_cache is called.
  class DataSet
    attr_accessor :asset

    class InsufficientDataError < StandardError; end

    # Allows for caching
    class DataClient
      include Singleton

      def bust_caches
        @data_from_cache = nil
      end

      def from_s3(asset, bust_cache:)
        # We currently don't ever cache S3 data
        if !bust_cache
          raise NotImplementedError
        end

        fog = FogConnections.s3_connection
        bucket = fog.directories.new(key: ENV["CARRIER_WAVE_BUCKET_NAME"])

        file = bucket.files.get(file_name(asset))

        if file.nil?
          nil
        else
          JSON.parse(file.body)
        end
      end

      def to_s3(asset, data)
        fog = FogConnections.s3_connection
        bucket = fog.directories.new(key: ENV["CARRIER_WAVE_BUCKET_NAME"])

        file = bucket.files.get(file_name(asset))

        if file.nil?
          bucket.files.create(
            key: file_name(asset),
            body: data
          )
        else
          file.body = data
          file.save
        end
      end

      def from_cache(asset, bust_cache:)
        @data_from_cache ||= {}

        if bust_cache
          @data_from_cache[cache_key(asset)] = nil
        end

        @data_from_cache[cache_key(asset)] ||= Rails.cache.fetch(file_name(asset))

        if @data_from_cache[cache_key(asset)].nil?
          nil
        else
          JSON.parse(@data_from_cache[cache_key(asset)])
        end
      end

      def to_cache(asset, data)
        @data_from_cache ||= {}
        @data_from_cache[cache_key(asset)] = data

        Rails.cache.write(file_name(asset), data)
      end

      private

      def cache_key(asset)
        :"#{asset.type}:#{asset.name}"
      end

      def file_name(asset)
        "asset_prices/#{asset.type}/#{asset.name}/data.json"
      end
    end

    def initialize(asset)
      self.asset = asset
    end

    def fetch_for_date(date)
      # TODO: Super, super hacky way of reducing memcached calls
      if @cache_last_busted_at.nil? || @cache_last_busted_at < 10.seconds.ago
        bust_cache = true
        @cache_last_busted_at = Time.now
      else
        bust_cache = false
      end

      data = DataClient.instance.from_cache(asset, bust_cache: bust_cache)
      date_formatted = StringifyTime.stringify(date, :day)
      rate = data.try!(:[], date_formatted)

      if rate.nil?
        raise InsufficientDataError
      else
        rate
      end
    end

    # Assumes lock
    def populate(dates)
      existing_data = DataClient.instance.from_s3(asset, bust_cache: true) || {}

      dates.each do |date|
        date_formatted = StringifyTime.stringify(date, :day)
        existing_data[date_formatted] = rate_request.rate(date)
      end

      DataClient.instance.to_s3(asset, existing_data.to_json)
      DataClient.instance.to_cache(asset, existing_data.to_json)
    end

    private

    def rate_request
      @rate_request ||= RateRequest.new(asset)
    end
  end

  class RateRequest
    attr_accessor :asset

    # Cache OXR requests per-request.
    class OpenExchangeRatesFetcher
      include Singleton

      def bust_caches
        @data = nil
      end

      def historical(asset, date)
        @data ||= {}
        date_formatted = StringifyTime.stringify(date, :open_exchange_rates)

        @data[date] ||= currency_connection.get(
          "/api/historical/#{date_formatted}.json?app_id=#{ENV["OPEN_EXCHANGE_RATES_APP_ID"]}"
        ).body
        @data[date]["rates"][asset.name]
      end

      private

      def currency_connection
        conn = Faraday.new(url: "https://openexchangerates.org") do |faraday|
          faraday.response :logger                  # log requests to STDOUT
          faraday.response :json                    # parse JSON
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end
    end

    def initialize(asset)
      self.asset = asset
    end

    # Cache only works on currency assets
    def rate(date)
      case asset.type
      when :currency
        OpenExchangeRatesFetcher.instance.historical(asset, date)
      when :stock
        if date.today?
          begin
            result = StockQuote::Stock.quote(asset.name)
            result.last_trade_price_only
          rescue StockQuote::NoDataForStockError
            rate(date.prev_day)
          end
        else
          result = StockQuote::Stock.history(asset.name, date, date)

          if result.instance_of?(StockQuote::NoDataForStockError)
            rate(date.prev_day)
          else
            result.first.close
          end
        end
      else
        raise NotImplementedError, asset.type
      end
    end
  end
end
