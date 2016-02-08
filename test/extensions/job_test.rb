require_relative './../test_helper'

class JobTest < ActiveSupport::TestCase

  def setup
    Delayed::Worker.delay_jobs = true
  end

  def test_job_default
    thing = Thing.create(name: 'test')
    thing.delay.something

    job = Delayed::Job.last
    assert_equal thing, job.record
    assert_equal 0, job.progress_current
    assert_equal 100, job.progress_max
    assert_equal nil, job.identifier
    assert_equal nil, job.queue
  end

  def test_job_custom
    thing = Thing.create(name: 'test')
    job = Delayed::Job.enqueue(TestJob.new(thing.id))

    assert_equal thing, job.record
    assert_equal 500, job.progress_current
    assert_equal 1000, job.progress_max
    assert_equal 'unique_identifier', job.identifier
    assert_equal 'reports', job.queue
    assert_equal 'TestJob', job.handler_class
  end

  def test_job_enqueue_with_existing_identifier
    thing = Thing.create(name: 'test')
    Delayed::Job.enqueue(TestJob.new(thing.id))

    # should not be able to queue a job that already exists
    # in this case we're trying to enqueue a job with `unique_identifier` again
    assert_exception DelayedJobProgress::DuplicateJobError do
      Delayed::Job.enqueue(TestJob.new(thing.id))
    end
  end

  def test_job_enqueue_with_existing_identifier_and_completed
    thing = Thing.create(name: 'test')
    job = Delayed::Job.enqueue(TestJob.new(thing.id))
    job.update_column(:completed_at, Time.now)

    Delayed::Job.enqueue(TestJob.new(thing.id))
  end

  def test_job_enqueue_with_existing_identifier_and_failed
    thing = Thing.create(name: 'test')
    job = Delayed::Job.enqueue(TestJob.new(thing.id))
    job.update_column(:failed_at, Time.now)

    Delayed::Job.enqueue(TestJob.new(thing.id))
  end

  def test_job_destroy
    thing = Thing.create(name: 'test')
    job = Delayed::Job.enqueue(TestJob.new(thing.id))

    assert job.completed_at.blank?
    assert_no_difference 'Delayed::Job.count' do
      job.destroy
      assert job.completed_at.present?
    end

    assert_difference 'Delayed::Job.count', -1 do
      job.destroy(:force)
    end
  end

  def test_job_reserve_completed
    thing = Thing.create(name: 'test')
    worker = Delayed::Worker.new
    job = Delayed::Job.enqueue(TestJob.new(thing.id))

    # marking it as complete
    job.update_column(:completed_at, Time.now)
    Delayed::Job.reserve(worker)
    job.reload
    assert job.locked_at.nil?
    assert job.locked_by.nil?

    # and here's the default
    job.update_column(:completed_at, nil)
    Delayed::Job.reserve(worker)
    job.reload
    refute job.locked_at.nil?
    refute job.locked_by.nil?
  end
end