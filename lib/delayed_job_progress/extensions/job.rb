Delayed::Backend::ActiveRecord::Job.class_eval do

  belongs_to :record, :polymorphic => true

  # When enqueue hook is executed, we need to look if there's an identifier provided
  # If there's another Delayed::Job out there with same identifier we need to bail
  def hook(name, *args)
    super

    if name == :enqueue && self.identifier.present?
      if Delayed::Job.where(:identifier => self.identifier, :completed_at => nil, :failed_at => nil).any?
        raise DelayedJobProgress::DuplicateJobError, "Delayed::Job with identifier: #{self.identifier} already present"
      end
    end
  end

  # Associating AR record with Delayed::Job. Generally when doing: `something.delay.method`
  def payload_object=(object)
    if object.respond_to?(:object) && object.object.is_a?(ActiveRecord::Base)
      self.record = object.object
    end

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
