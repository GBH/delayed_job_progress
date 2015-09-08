require_relative './../test_helper'

class JobTest < ActiveSupport::TestCase

  def test_active_record_default
    Delayed::Worker.delay_jobs = true
    thing = Thing.create(:name => 'test')
    thing.delay.something

    job = Delayed::Job.last
    assert_equal 0, job.progress_current
    assert_equal 100, job.progress_max
    assert_equal thing, job.record
  end

end