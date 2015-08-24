class AddProgressToDelayedJobs < ActiveRecord::Migration

  def change
    change_table :delayed_jobs do |t|
      t.string    :identifier
      t.string    :record_type
      t.integer   :record_id
      t.integer   :progress_current,  :null => false, :default => 0
      t.integer   :progress_max,      :null => false, :default => 100
      t.string    :progress_state
      t.datetime  :completed_at
    end

    add_index :delayed_jobs, :identifier
    add_index :delayed_jobs, [:record_type, :record_id]
    add_index :delayed_jobs, :completed_at
  end

end