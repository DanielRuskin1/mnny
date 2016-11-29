FactoryGirl.define do
  factory :balance_record do
    balance_record_set
    amount 1
    effective_date Date.today
  end
end
