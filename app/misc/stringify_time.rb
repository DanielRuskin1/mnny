# Standard format for stringifying time
class StringifyTime
  def self.stringify(time, type)
    case type
    when :day
      time.strftime("%m/%d/%Y")
    when :open_exchange_rates # Formatted for OXR
      time.strftime("%Y-%m-%d")
    when :ecb # Formatted for ECB XML files
      time.strftime("%Y-%m-%d")
    when :all
      time.strftime("%m/%d/%Y %H:%M %p %Z")
    else
      raise NotImplementedError, type
    end
  end
end
