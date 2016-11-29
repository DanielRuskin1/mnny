class ApplicationRecord < ActiveRecord::Base
  after_create :track_create

  self.abstract_class = true

  private

  def track_create
    KeenTracking.track_async(:"new_#{self.class.name}s", tracking_params)
  end

  def tracking_params
    { id: id }
  end
end
