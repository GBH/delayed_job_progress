# DelayedJobProgress
[![Gem Version](https://img.shields.io/gem/v/delayed_job_progress.svg?style=flat)](http://rubygems.org/gems/delayed_job_progress) [![Gem Downloads](https://img.shields.io/gem/dt/delayed_job_progress.svg?style=flat)](http://rubygems.org/gems/delayed_job_progress) [![Build Status](https://img.shields.io/travis/GBH/delayed_job_progress.svg?style=flat)](https://travis-ci.org/GBH/delayed_job_progress)

Extension for [Delayed::Job](https://github.com/collectiveidea/delayed_job) that allows for better tracking of jobs!

![progress](https://raw.githubusercontent.com/GBH/delayed_job_progress/master/progress.gif)

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
  has_many :jobs, :as => :record, :class_name => 'Delayed::Job'
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
    job.record            = User.find(user_id)
    job.identifier        = 'unique_identifier'
    job.progress_max      = 100
    job.progress_current  = 0
  end

  def before(job)
    @job  = job
    @user = job.record
  end

  def perform
    @job.update_column(:message, 'working')
    (0..100).each do |i|
      @user.do_a_thing(i)
      @job.update_column(:progress_current, i)
    end
    @job.update_column(:message, 'complete')
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
```
`progress_max`      - Default is `100`. You can change it to whatever during `enqueue`.
`progress_current`  - Default is `0`. You can manually increment it while job is running.
                      Will be set to `process_max` when job completes.
`message`           - Default is `nil`. Optional informational string.
`error_message`     - Error message without backtrace. Also useful to set your own message.
`completed_at`      - When job is done this timestamp is recorded.
`identifier`        - You can assign something during `enqueue` so you can fetch that job later for display.
`status`            - Virtual read-only attribute. Can be `queued`, `processing`, `completed` or `failed`
```

This extension also introduces worker setting that keeps completed jobs around. This way you can keep list of completed jobs for a while. If you want to remove them, you need to `.destroy(:force)` them.
```
Delayed::Worker.destroy_completed_jobs = false
```

## Jobs Controller

You may mount jobs controller in your routes by adding:

```ruby
mount DelayedJobProgress::Engine => '/delayed'
```

Following JSON serving end-points will become available:

```
GET /jobs               - List all jobs. Can filter based on associated record via `record_type` and `record_id`
                          parameters. `identifier` parameter can be used as well
GET /jobs/<id>          - Status of a job. Will see all the Delayed::Job attributes including things like progress
DELETE /jobs/<id>`      - If job is stuck/failed, we can remove it
POST /jobs/<id>/reload` - Restart failed job
```

## Front-end
This gem doesn't have a front-end component to show fancy progress bar. Common way to accomplish that would be to create a javascript poller that would periodically hit `/jobs/<id>` enpoint and update progress bar with progress data + messages.

---

Copyright 2016-17 Oleg Khabarov