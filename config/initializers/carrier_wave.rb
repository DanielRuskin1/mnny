CarrierWave.configure do |config|
  config.fog_provider = "fog/aws"
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: ENV["CARRIER_WAVE_AWS_KEY_ID"],
    aws_secret_access_key: ENV["CARRIER_WAVE_AWS_SECRET_ACCESS_KEY"],
    region: ENV["CARRIER_WAVE_AWS_REGION"]
  }
  config.fog_directory = ENV["CARRIER_WAVE_BUCKET_NAME"]
end
