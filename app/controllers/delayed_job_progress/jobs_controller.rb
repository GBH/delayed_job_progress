module DelayedJobProgress
  class JobsController < ActionController::Base

    before_action :load_job, only: [:show, :destroy, :reload]

    def index
      jobs = Delayed::Job
      if params[:record_type].present? && params[:record_id].present?
        jobs = jobs.where(record_type: params[:record_type], record_id: params[:record_id])
      end
      if params[:identifier].present?
        jobs = jobs.where(identifier: params[:identifier])
      end

      render json: jobs.all
    end

    def show
      render json: @job
    end

    def destroy
      @job.destroy(:force)
      head :no_content
    end

    def reload
      @job.update_columns(
        run_at:       Time.now,
        failed_at:    nil,
        completed_at: nil,
        locked_by:    nil,
        locked_at:    nil,
        last_error:   nil,
        attempts:     0
      )
      render json: @job
    end

  protected

    def load_job
      @job = Delayed::Job.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {error: 'Job not found'}, status: :not_found
    end

  end
end