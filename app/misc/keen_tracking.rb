class KeenTracking
  def self.track_async(event_name, event_params)
    job = JobRequest.new
    job.job_class = KeenJob
    job.job_params = {
      "event_name" => event_name,
      "event_params" => event_params
    }
    job.save!
  end

  def self.track(event_name, event_params)
    if Rails.env.production?
      Keen.publish(event_name, event_params)
    end
  end
end
