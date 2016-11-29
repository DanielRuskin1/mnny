require "rails_helper"
require "features/feature_test_helper"

RSpec.feature "Accounts", type: :feature do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:balance_record_set) { create(:balance_record_set, account: account) }
  let(:balance_record) { create(:balance_record, balance_record_set: balance_record_set) }

  before do
    signin(user)
  end

  scenario "User views their summary", js: true do
    balance_record

    Timecop.freeze do
      conversion_request_instance = AssetPriceTracker::ConversionRequest.new(
        1.0,
        "JPY",
        "USD",
        Time.now
      )
      allow(conversion_request_instance).to receive(:result).and_return(0.01)
      allow(AssetPriceTracker::ConversionRequest)
        .to receive(:new)
        .with(1.0, instance_of(AssetPriceTracker::Asset), instance_of(AssetPriceTracker::Asset), instance_of(Time))
        .and_return(conversion_request_instance)

      visit summary_index_path
      expect(page).to have_content("$0.01")

      find(".account-balance-tooltip[data-account-id='#{account.id.to_s}']").hover
      expect(page).to have_content("¥1 (~$0.01)")
    end
  end
end
