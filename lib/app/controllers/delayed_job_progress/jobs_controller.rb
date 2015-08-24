module DelayedJobProgress
  class JobsController < ActionController::Base
    def show
      @job = Delayed::Job.find(params[:id])
      render :json => @job
    rescue ActiveRecord::RecordNotFound
      render :json => {:error => 'Job not found'}, :status => :not_found
    end
  end
end