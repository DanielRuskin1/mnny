class KeenJob < ApplicationJob
  def perform(params)
    KeenTracking.track(params["event_name"], params["event_params"])
  end
end
