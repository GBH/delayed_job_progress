require_relative './../test_helper'

class WorkerTest < ActiveSupport::TestCase

  def setup
    Delayed::Worker.delay_jobs = true
  end

  def teardown
    Delayed::Worker.destroy_completed_jobs = false
  end

  def test_run_job
    thing = Thing.create(:name => 'test')
    job = Delayed::Job.enqueue(TestJob.new(thing.id))

    worker = Delayed::Worker.new
    worker.run(job)

    job.reload

    assert job.completed_at.present?
    assert_equal 1000, job.progress_current
    assert_equal 'complete', job.progress_state
  end

  def test_run_job_and_destroy
    Delayed::Worker.destroy_completed_jobs = true

    thing = Thing.create(:name => 'test')
    thing.delay.something

    job = Delayed::Job.last

    assert_difference 'Delayed::Job.count', -1 do
      worker = Delayed::Worker.new
      worker.run(job)
    end
  end
end
