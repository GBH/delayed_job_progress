Delayed::Backend::ActiveRecord::Job.class_eval do

  belongs_to :record, polymorphic: true

  # Overriding default scope so we don't select already completed jobs
  def self.ready_to_run(worker_name, max_run_time)
    where_sql = <<-SQL.strip_heredoc
      (run_at <= ? AND (locked_at IS NULL OR locked_at < ?) OR locked_by = ?)
      AND failed_at IS NULL
      AND completed_at IS NULL
    SQL
    where(where_sql, db_time_now, db_time_now - max_run_time, worker_name)
  end

  # When enqueue hook is executed, we need to look if there's an identifier provided
  # If there's another Delayed::Job out there with same identifier we need to bail
  def hook(name, *args)
    super

    if name == :enqueue
      self.handler_class = payload_object.class.to_s
      if self.identifier.present?
        if Delayed::Job.where(identifier: self.identifier, completed_at: nil, failed_at: nil).any?
          raise DelayedJobProgress::DuplicateJobError, "Delayed::Job with identifier: #{self.identifier} already present"
        end
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
        completed_at:     Time.zone.now,
        progress_current: self.progress_max,
        locked_at:        nil,
        locked_by:        nil
      )
    end
  end
end
