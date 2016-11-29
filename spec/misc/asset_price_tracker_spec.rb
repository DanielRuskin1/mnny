require "rails_helper"
require "misc/misc_spec_helper"

RSpec.describe AssetPriceTracker do
  describe "ConversionRequest#result" do
    it "should get data from the data sets and return the result" do
      effective_date = 1.day.ago
      effective_date_as_string = StringifyTime.stringify(effective_date, :day)

      expect(Rails.cache)
        .to receive(:fetch)
        .with("asset_prices/stock/AAPL/data.json")
        .and_return({ effective_date_as_string => 500.0 }.to_json)
      expect(Rails.cache)
        .to receive(:fetch)
        .with("asset_prices/currency/JPY/data.json")
        .and_return({ effective_date_as_string => 113.0 }.to_json)

      request = AssetPriceTracker::ConversionRequest.new(
        1,
        AssetPriceTracker::Asset.new(:stock, "AAPL"),
        AssetPriceTracker::Asset.new(:currency, "JPY"),
        effective_date
      )
      expect(request.result).to eq(56500.0)
    end
  end

  describe ".populate_data_sets" do
    it "should populate the data sets", enable_cache: true do
      effective_date = 1.day.ago
      effective_date_as_string = StringifyTime.stringify(effective_date, :day)

      asset = AssetPriceTracker::Asset.new(:stock, "AAPL")
      data_set = AssetPriceTracker::DataSet.new(asset)

      expect do
        data_set.fetch_for_date(effective_date)
      end.to raise_error(AssetPriceTracker::DataSet::InsufficientDataError)

      # TODO: Fix ugly stubs
      allow(FogConnections)
        .to receive_message_chain(:s3_connection, :directories, :new, :files, :create)
        .and_return(true)
      allow(FogConnections)
        .to receive_message_chain(:s3_connection, :directories, :new, :files, :get)
        .and_return(nil)

      stubbed_quote = StockQuote::Stock.new({ "Symbol" => "AAPL", "close" => "500.0" })
      allow(StockQuote::Stock)
        .to receive(:history).with("AAPL", effective_date, effective_date)
        .and_return([stubbed_quote])
      AssetPriceTracker.populate_data_sets([effective_date], [asset])

      expect(data_set.fetch_for_date(1.day.ago)).to eq(500.0)
    end
  end
end
