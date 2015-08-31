Delayed::Backend::ActiveRecord::Job.class_eval do

  belongs_to :record, :polymorphic => true

  def payload_object=(object)
    self.record = object.object if object.object.is_a?(ActiveRecord::Base)
    super
  end

  def destroy_completed_jobs?
    payload_object.respond_to?(:destroy_completed_jobs?) ?
      payload_object.destroy_completed_jobs? :
      Delayed::Worker.destroy_completed_jobs
  end

  def destroy(force_destroy = false)
    if destroy_completed_jobs? || force_destroy
      super()
    else
      update_columns(
        :completed_at     => Time.zone.now,
        :progress_current => self.progress_max
      )
    end
  end
end
