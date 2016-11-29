# Guarantees at-least-once, eventual processing.
class JobRequest < ApplicationRecord
  VALID_JOBS = [
    "KeenJob"
  ]

  validates :job_class_string, presence: true, inclusion: { in: VALID_JOBS }
  validates :job_params_json, presence: true

  def self.process_job_requests
    ActiveRecord::Base.with_advisory_lock(LockKeys.process_job_requests) do
      JobRequest.all.each do |job_request|
        job_request.process
      end
    end
  end

  # Assumes lock
  def process
    job_class.new.perform(job_params)
    destroy!

    true
  end

  def job_class
    job_class_string.constantize
  end

  def job_class=(klass)
    self.job_class_string = klass.to_s
  end

  def job_params
    JSON.parse(job_params_json)
  end

  # Only string keys are supported
  def job_params=(hash)
    self.job_params_json = hash.to_json
  end

  private

  def track_create
    # Don't track JobRequest creation, as this would lead to an infinite lookups
    # (JobRequest create -> Keen tracking -> JobRequest create -> etc)
  end
end
