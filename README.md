# Delayed::Job Progress

Extension for `DelayedJob` that allows better tracking of jobs!

## Setup

* add to Gemfile: `gem 'delayed_job_progress'`
* `bundle install`
* `rails g delayed_job:progress`
* `rake db:migrate`

## Configuration and Usage

Consider this:

```ruby
class User < ActiveRecord::Base
  # convenient relationship to grab associated jobs
  has_many :jobs, :as => :record, :class_name => 'DelayedJob'
end
```

Creating a delayed job:
```ruby
user = User.find(123)
user.delay.do_things!
```

If you're using custom jobs you'll need to do something like this:
```ruby
class CustomUserJob < Struct.new(:user_id)
  def enqueue(job)
    job.record = User.find(user_id)
  end
end

Delayed::Job.enqueue CustomUserJob.new(123)
```

This will create a Delayed::Job record:
```ruby
-> user.jobs
=> [#<Delayed::Job>]
```

That job knows about object that spawned it:
```ruby
-> Delayed::Job.last.record
=> #<User>
```

`Delayed::Job` records now have new attributes:
* `process_max` - default is `100`. You can change it to whatever during `enqueue`.
* `process_current` - default is `0`. You can manually increment it while job is running. Will be set to `process_max` when job completes.
* `process_state` - default is `nil`. Optional informational string.
* `completed_at` - when job is done this timestamp is recorded.

This extension also introduces worker setting that keeps completed jobs around. This way you can keep list of completed jobs for a while. If you want to remove them, you need to `.destroy(:force)` them.
```
Delayed::Worker.destroy_completed_jobs = false
```

## Jobs Controller

- `GET /jobs` - List all jobs. Can filter based on associated record via `record_type` and `record_id` parameters. `identifier` parameter can be used as well
- `GET /jobs/<id>` - Status of a job. Will see all the Delayed::Job attributes including things like progress
- `DELETE /jobs/<id>` - If job is stuck/failed, we can remove it
- `POST /jobs/<id>/restart` - Restart failed job

