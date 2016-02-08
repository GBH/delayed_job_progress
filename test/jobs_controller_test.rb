require_relative './test_helper'

module DelayedJobProgress
  class JobsControllerTest < ActionController::TestCase

    def setup
      @routes = Engine.routes
      Delayed::Worker.delay_jobs = true

      @thing = Thing.create(name: 'test')
      @job = Delayed::Job.enqueue(TestJob.new(@thing.id))
    end

    def test_index
      get :index
      assert_response :success
      assert_equal 1, JSON.parse(response.body).count
    end

    def test_index_record_filtering
      get :index, record_type: @thing.class, record_id: @thing.id
      assert_response :success
      data = JSON.parse(response.body)
      assert data.is_a?(Array)
      assert_equal 1, data.count

      get :index, record_type: 'invalid', record_id: @thing.id
      assert_response :success
      assert_equal [], JSON.parse(response.body)

      get :index, record_type: @thing.class, record_id: 'invalid'
      assert_response :success
      assert_equal [], JSON.parse(response.body)
    end

    def test_show
      get :show, id: @job.id
      assert_response :success
      data = JSON.parse(response.body)
      assert_equal 'unique_identifier', data['identifier']
      assert_equal 'Thing',             data['record_type']
      assert_equal 1,                   data['record_id']
      assert_equal 500,                 data['progress_current']
      assert_equal 1000,                data['progress_max']
      assert_equal 'initialized',       data['progress_state']
    end

    def test_show_failure
      get :show, id: 'invalid'
      assert_response :not_found
      assert_equal ({'error' => 'Job not found'}), JSON.parse(response.body)
    end

    def test_destroy
      assert_difference 'Delayed::Job.count', -1 do
        delete :destroy, id: @job.id
        assert_response :no_content
      end
    end

    def test_reset
      @job.update_column(:failed_at, Time.now)

      post :reload, id: @job
      assert_response :success

      @job.reload
      assert @job.failed_at.blank?
    end
  end
end