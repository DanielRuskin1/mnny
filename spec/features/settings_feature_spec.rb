require "rails_helper"
require "features/feature_test_helper"

RSpec.feature "Settings", type: :feature do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:balance_record_set) { create(:balance_record_set, account: account) }
  let(:balance_record) { create(:balance_record, balance_record_set: balance_record_set) }

  before do
    signin(user)
    visit settings_path
  end

  scenario "User updates their settings" do
    select "Lima", from: "Timezone"
    select "JPY", from: "Base Currency"
    select "Daily", from: "Reminder Period"
    select "Weekly", from: "Backup Period"
    click_button("Submit")

    expect(page).to have_content("Settings saved!")

    user.reload
    expect(user.timezone).to eq("Lima")
    expect(user.base_currency).to eq("JPY")
    expect(user.reminder_period).to eq("daily")
    expect(user.backup_period).to eq("weekly")
  end

  scenario "User exports their data" do
    balance_record
    
    click_link("Export")

    header = page.response_headers["Content-Disposition"]
    expect(header).to eq("attachment; filename=\"Net-Worth-Export.csv\"")
  end
end
