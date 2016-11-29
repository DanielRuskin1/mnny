FactoryGirl.define do
  factory :user do
    sequence :name do |n|
      "Test User #{n}"
    end
    base_currency "USD"
    sequence :email do |n|
      "test#{n}@example.com"
    end
    omniauth_uid { |u| u.email }
  end
end
