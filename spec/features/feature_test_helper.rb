def signin(user)
  visit "/auth/developer"
  fill_in "name", with: user.name
  fill_in "email", with: user.email
  click_button "Sign In"
end

def include_hidden_fields
  Capybara.ignore_hidden_elements = false
  yield
  Capybara.ignore_hidden_elements = true
end
