class AccountImportUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader

  alias_method :extension_white_list, :extension_whitelist
end
