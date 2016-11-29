include CarrierWaveDirect::Test::Helpers

FactoryGirl.define do
  factory :account_import do
    key sample_key(AccountImportUploader.new)
    account
  end
end
