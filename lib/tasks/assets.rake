namespace :assets do
  desc "Tracks prices."
  task track_prices: :environment do
    AssetPriceTracker.populate_data_sets([Date.today])
  end

  desc "Seed new assets."
  task seed_new_assets: :environment do
    historical_dates = (0..400).map { |i| i.days.ago }
    AssetPriceTracker.populate_data_sets(
      historical_dates,
      AssetPriceTracker::Asset.unseeded_assets
    )
  end
end
