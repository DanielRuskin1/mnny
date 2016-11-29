require "rails_helper"
require "features/feature_test_helper"

RSpec.feature "Root", type: :feature do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:balance_record_set) { create(:balance_record_set, account: account) }
  let(:balance_record) { create(:balance_record, balance_record_set: balance_record_set) }

  before do
    signin(user)
  end

  scenario "User sees the 'add an account' button" do
    visit root_path

    expect(page).to have_content("Add an account")
  end

  scenario "User sees the 'add your account balances' button" do
    account
    visit root_path

    expect(page).to have_content("Add your account balances")
  end

  scenario "User sees the 'take a look at your current net worth' button" do
    balance_record
    visit root_path

    expect(page).to have_content("Take a look at your current net worth")
  end
end
