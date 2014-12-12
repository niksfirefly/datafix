require 'rails/generators/active_record'

class Datafix
  module Generators
    class UpgradeGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      # Implement the required interface for Rails::Generators::Migration.

      source_root File.expand_path("../templates", __FILE__)

      def generate
        generate_from_template("upgrade_datafix_tables")
      end

      private

      def generate_from_template(migration_name)
        migration_dir = "db/migrate"

        if ActiveRecord::Generators::Base.migration_exists?(migration_dir, migration_name)
          puts "** Another migration is already named #{migration_name}: #{migration_dir}! Skipping."
        else
          migration_number = ActiveRecord::Generators::Base.next_migration_number(migration_dir)
          copy_file "#{migration_name}.rb", "#{migration_dir}/#{migration_number}_#{migration_name}.rb"
        end
      end
    end
  end
end

