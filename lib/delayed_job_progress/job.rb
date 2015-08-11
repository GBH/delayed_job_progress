Delayed::Backend::ActiveRecord::Job.class_eval do

  def destroy_completed_jobs?
    payload_object.respond_to?(:destroy_completed_jobs?) ?
      payload_object.destroy_completed_jobs? :
      Delayed::Worker.destroy_completed_jobs
  end

  def destroy(force_destroy = false)
    if destroy_completed_jobs? || force_destroy
      super()
    else
      update_column(:completed_at, Time.zone.now)
    end
  end
end
