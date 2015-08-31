Rails.application.routes.draw do

  mount DelayedJobProgress::Engine => "/delayed_job_progress"
end
