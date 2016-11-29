require "rails_helper"
require "features/feature_test_helper"
include CarrierWaveDirect::Test::CapybaraHelpers

RSpec.feature "Accounts", type: :feature do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let(:balance_record_set) { create(:balance_record_set, account: account) }
  let(:balance_record) { create(:balance_record, balance_record_set: balance_record_set) }

  before do
    signin(user)
  end

  scenario "User creates an account", js: true do
    visit accounts_path

    fill_in "Name", with: "Test Account"
    expect do
      click_button("Submit")
      expect(page).to have_content("Account created!")
    end.to change(user.accounts, :count).by(1)

    expect(page).to have_content("Test Account")
  end

  scenario "User creates a balance record set (currency)", js: true do
    account
    visit accounts_path

    find(".currency-dropdown").select("JPY")
    expect do
      click_button("Add")
      expect(page).to have_content("Asset created!")
    end.to change(account.balance_record_sets, :count).by(1)

    balance_record_set = account.balance_record_sets.last
    expect(page).to have_css("#balance-record-set-#{balance_record_set.id}")

    expect(balance_record_set.asset_type).to eq(:currency)
    expect(balance_record_set.asset_name).to eq("JPY")
  end

  scenario "User creates a balance record set (stock)", js: true do
    account
    visit accounts_path

    find(".asset-type-dropdown").select("Stock")
    find(".stock-field").set("AAPL")
    expect do
      click_button("Add")
      expect(page).to have_content("Asset created!")
    end.to change(account.balance_record_sets, :count).by(1)

    balance_record_set = account.balance_record_sets.last
    expect(page).to have_css("#balance-record-set-#{balance_record_set.id}")

    expect(balance_record_set.asset_type).to eq(:stock)
    expect(balance_record_set.asset_name).to eq("AAPL")
  end

  scenario "User deletes a balance record set", js: true do
    balance_record_set
    visit accounts_path

    expect(page).to have_css("#balance-record-set-#{balance_record_set.id}")
    expect do
      within ".delete-balance-record-set" do
        click_link "Delete"
      end
      expect(page).to_not have_css("#balance-record-set-#{balance_record_set.id}")
    end.to change(account.balance_record_sets, :count).by(-1)
  end

  scenario "User creates a balance record", js: true do
    balance_record_set
    visit accounts_path

    fill_in "balance_record_amount", with: "100"
    expect do
      click_button "Set Balance"
      expect(page).to have_content("Balance record created!")
    end.to change(balance_record_set.balance_records, :count).by(1)

    record = balance_record_set.balance_records.last
    expect(page).to have_css("#balance-record-#{record.id}")
  end

  scenario "User deletes a balance record", js: true do
    balance_record
    visit accounts_path

    expect(page).to have_css("#balance-record-#{balance_record.id}")
    expect do
      within "#balance-record-#{balance_record.id}" do
        click_link "×"
      end
      expect(page).to_not have_css("#balance-record-#{balance_record.id}")
    end.to change(balance_record_set.balance_records, :count).by(-1)
  end

  # TODO: make this not use S3
  scenario "User starts an account import", js: true do
    account
    visit accounts_path

    click_link("Import")

    include_hidden_fields do
      attach_file("Choose", "spec/fixtures/account_import.csv")
    end
    within ".new_account_import_uploader" do
      expect do
        click_button "Submit"
      end.to change(account.account_imports, :count).by(1)
    end
  end
end
