require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'database_cleaner'
require 'pry'
require 'timecop'

require 'pg'
require 'datafix'

PG_SPEC = {
  :adapter  => 'postgresql',
  :host     => 'localhost',
  :database => 'datafix_test',
  :username => ENV['USER'],
  :encoding => 'utf8'
}

ActiveRecord::Base.establish_connection(PG_SPEC.merge('database' => 'postgres', 'schema_search_path' => 'public'))
# drops and create need to be performed with a connection to the 'postgres' (system) database
# drop the old database (if it exists)
ActiveRecord::Base.connection.drop_database PG_SPEC[:database] rescue nil
# create new
ActiveRecord::Base.connection.create_database(PG_SPEC[:database])
ActiveRecord::Base.establish_connection(PG_SPEC)

require 'generators/datafix/install/templates/create_datafix_tables'
CreateDatafixTables.new.up

class DatafixLog < ActiveRecord::Base; end

ActiveRecord::Migration.create_table :kittens do |t|
  t.string :name
  t.boolean :fixed, default: false
  t.timestamps
end

class Kitten < ActiveRecord::Base; end

ActiveRecord::Migration.create_table :puppies do |t|
  t.string :name
  t.boolean :fixed, default: false
  t.timestamps
end

class Puppy < ActiveRecord::Base; end

require "action_controller/railtie"
class TestRailsApp < Rails::Application
  config.secret_token = "random_secret_token"
end

Rails.application.config.root = File.expand_path("../tmp_rails_app",__FILE__)

RSpec.configure do |config|
  config.color = true
  config.formatter     = 'documentation'

  config.before(:suite) do
    FileUtils.rm_rf(Rails.root)
    Dir.mkdir(Rails.root)

    FileUtils.mkdir_p(Rails.root.join("db", "datafixes"))
    Dir.glob("spec/datafixes/*.rb").each do |f|
      FileUtils.copy(f, Rails.root.join("db", "datafixes"))
      require Rails.root.join("db", "datafixes", File.basename(f))
    end

    TestRailsApp.initialize!
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Timecop.return
  end

  config.after(:suite) do
    FileUtils.rm_rf(Rails.root)
  end
end
