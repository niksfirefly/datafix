require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'database_cleaner'
require 'pry'

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

class DatafixLog < ActiveRecord::Base; end
class DatafixStatus < ActiveRecord::Base; end

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

Dir.glob("spec/datafixes/*.rb").each do |f| require "datafixes/#{File.basename f}" end

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
    TestRailsApp.initialize!
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    FileUtils.rm_rf(Rails.root)
  end
end
