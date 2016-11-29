require "rails_helper"
require "features/feature_test_helper"

RSpec.feature "Help", type: :feature do
  let(:user) { create(:user) }

  def common_form_submit
    fill_in("Subject", with: "Hello, world!")
    fill_in("Message", with: "Foo Bar!")
    click_button("Submit")

    expect(page).to have_content("Help request submitted")

    delivery = ActionMailer::Base.deliveries.last
    expect(delivery.to).to include(ENV["SUPPORT_EMAIL"])
    expect(delivery.subject).to eq("Support Request Received")
  end

  scenario "User is signed in", js: true do
    signin(user)
    visit help_index_path

    common_form_submit
  end

  scenario "User is not signed in", js: true do
    visit help_index_path
    fill_in("Email", with: "test@test.com")

    common_form_submit
  end
end
