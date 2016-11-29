class CreateJobRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :job_requests do |t|
      t.string :job_class_string
      t.string :job_params_json

      t.timestamps
    end

    change_column_null :job_requests, :job_class_string, false
    change_column_null :job_requests, :job_params_json, false
  end
end
