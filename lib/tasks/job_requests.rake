namespace :job_requests do
  desc "Process job requests."
  task process: :environment do
    JobRequest.process_job_requests
  end
end
