class SettingsController < ApplicationController
  before_action :require_current_user

  def edit
    params_to_update = settings_params
    current_user.transaction do
      [:reminder, :backup].each do |period_name|
        field_name = "#{period_name}_period"
        time_field_name = "last_#{period_name}"

        # Sanitize params (blank string = nil)
        params_to_update[field_name] = params_to_update[field_name].presence

        # If user is editing periods, reset the last_#{period}
        # so we do the next task exactly PERIOD from now.
        if settings_params[field_name] != current_user.send(field_name)
          params_to_update[time_field_name] = Time.now
        end
      end

      current_user.update_attributes(params_to_update)
    end

    if current_user.errors.any?
      flash[:danger] = "Error!  " + current_user.errors.full_messages.join(", ")
    else
      flash[:success] = "Settings saved!"
    end

    redirect_to(settings_path)
  end

  def export_data
    send_data(DataExporter.export(current_user), filename: DataExporter.file_name)
  end

  private

  def settings_params
    params.require(:user).permit(:timezone, :base_currency, :reminder_period, :backup_period)
  end
end
