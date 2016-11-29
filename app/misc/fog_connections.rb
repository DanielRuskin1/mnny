class FogConnections
  class << self
    def s3_connection
      @s3_connection ||= Fog::Storage.new(
        provider: "AWS",
        aws_access_key_id: ENV["CARRIER_WAVE_AWS_KEY_ID"],
        aws_secret_access_key: ENV["CARRIER_WAVE_AWS_SECRET_ACCESS_KEY"],
        region: ENV["CARRIER_WAVE_AWS_REGION"]
      )
    end
  end
end
