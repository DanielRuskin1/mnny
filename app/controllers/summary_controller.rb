class SummaryController < ApplicationController
  before_action :require_current_user

  NET_WORTH_COLOR = "fuchsia"
  VALID_PERIODS = ["week", "month", "year"]

  def index
    conversion_effective_time = Time.now

    @accounts = current_user.accounts

    @balances = {
      accounts: {
        # Same as "totals" for each account
      },
      total: {
        sum: 0,
        assets: {}
      }
    }

    @accounts.each do |account|
      @balances[:accounts][account.id] = {
        sum: 0,
        assets: {}
      }

      # For each account, as well as the total, track;
      # 1. Sum, in native currency
      # 2. Latest balance for each currency
      account.balance_record_sets.each do |balance_record_set|
        asset = balance_record_set.asset_name
        most_recent_record = balance_record_set.most_recent_balance_record

        if most_recent_record.present?
          most_recent_record_amount = most_recent_record.amount
          most_recent_record_amount_converted = AssetPriceTracker::ConversionRequest.new(
            most_recent_record_amount,
            AssetPriceTracker::Asset.new(balance_record_set.asset_type, balance_record_set.asset_name),
            AssetPriceTracker::Asset.new(:currency, current_user.base_currency),
            conversion_effective_time
          ).result
        else
          most_recent_record_amount = 0
          most_recent_record_amount_converted = 0
        end

        @balances[:accounts][account.id][:assets][asset] = {
          type: balance_record_set.asset_type,
          raw: most_recent_record_amount,
          converted: most_recent_record_amount_converted
        }
        @balances[:accounts][account.id][:sum] += most_recent_record_amount_converted

        @balances[:total][:assets][asset] ||= {
          type: balance_record_set.asset_type,
          raw: 0,
          converted: 0
        }
        @balances[:total][:assets][asset][:raw] += most_recent_record_amount
        @balances[:total][:assets][asset][:converted] += most_recent_record_amount_converted
        @balances[:total][:sum] += most_recent_record_amount_converted
      end
    end
  rescue AssetPriceTracker::ConversionRequest::InsufficientDataError => e
    KeenTracking.track_async(:summary_data_unavailable, {})
    @data_unavailable = true
  end

  def get_chart_data
    accounts = current_user.accounts

    current_time_in_user_time_zone = Time.now.in_time_zone(current_user.timezone)
    days_to_get = case params[:period]
                  when "week"
                    (0..7).map { |t| (current_time_in_user_time_zone - t.days).end_of_day }
                  when "month"
                    (0..4).map { |t| (current_time_in_user_time_zone - t.weeks).end_of_day }
                  when "year"
                    (0..12).map { |t| (current_time_in_user_time_zone - t.months).end_of_day }
                  else
                    render(status: 400)
                  end

    chart_data = accounts.map do |account|
      data_points = []
      days_to_get.each do |day_to_get|
        if account.balance_record_sets.any?
          sum_of_balances = account.balance_record_sets.sum do |balance_record_set|
            relevant_record = balance_record_set
              .balance_records
              .where("effective_date < ?", day_to_get)
              .order(effective_date: :desc)
              .order(created_at: :desc)
              .first

            if relevant_record.present?
              AssetPriceTracker::ConversionRequest.new(
                relevant_record.amount,
                AssetPriceTracker::Asset.new(balance_record_set.asset_type, balance_record_set.asset_name),
                AssetPriceTracker::Asset.new(:currency, current_user.base_currency),
                day_to_get
              ).result
            else
              0
            end
          end
        else
          sum_of_balances = 0
        end

        data_points << {
          time: day_to_get,
          raw: sum_of_balances
        }
      end

      { name: account.name, color: account.color, data: data_points }
    end

    # Generate sum
    sum_data = {}
    chart_data.each do |data_set|
      data_points = data_set[:data]
      data_points.each do |data_point|
        day = data_point[:time]
        amount = data_point[:raw]

        if sum_data[day].nil?
          sum_data[day] = amount
        else
          sum_data[day] += amount
        end
      end
    end
    chart_data_to_add = {
      name: "Net Worth",
      color: NET_WORTH_COLOR,
      data: []
    }
    sum_data.each do |time, sum|
      chart_data_to_add[:data] << {
        time: time,
        raw: sum
      }
    end
    chart_data << chart_data_to_add

    # Convert chart datapoints to money floats + user's timezone
    chart_data = chart_data.map do |data_set|
      new_data_set = data_set[:data].map do |data_point|
        {
          time: StringifyTime.stringify(data_point[:time], :day),
          as_float: data_point[:raw],
          formatted: data_point[:raw].to_money(current_user.base_currency).format
        }
      end

      { name: data_set[:name], color: data_set[:color], data: new_data_set }
    end

    render(json: chart_data)
  rescue AssetPriceTracker::ConversionRequest::InsufficientDataError
    KeenTracking.track_async(:chart_data_unavailable, {})
    render(json: { unavailable: true }.to_json)
  end
end
