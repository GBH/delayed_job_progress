require 'rails/generators/active_record'

module DelayedJob
  class ProgressGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_paths << File.join(File.dirname(__FILE__), 'templates')

    def create_migration_file
      migration_template 'migrate/progress_migration.rb', 'db/migrate/add_progress_to_delayed_jobs.rb'
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number dirname
    end
  end
end