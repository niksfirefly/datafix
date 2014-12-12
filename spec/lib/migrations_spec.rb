require "spec_helper"
require 'generators/datafix/upgrade/templates/upgrade_datafix_tables'

describe "Datafix Migrations" do
  before(:each) do
    ActiveRecord::Migration.drop_table :datafix_logs
    ActiveRecord::Migration.drop_table :datafix_statuses

    # Intentionally datafix_log (no s) because of old migration
    ActiveRecord::Migration.create_table :datafix_log do |t|
      t.string :direction
      t.string :script
      t.timestamp :timestamp
    end
  end

  def sanitize(value)
    ActiveRecord::Base.connection.quote(value)
  end

  describe "migrating from previous Datafix installation" do
    let(:migration) { UpgradeDatafixTables.new }
    let(:timestamp) { '2014-10-05 05:00' }

    before do
      # Seed log with events but leave statuses empty.
      DatafixLog.connection.execute(<<-SQL)
      INSERT INTO datafix_log (direction, script, timestamp)
      VALUES
      ('up', 'FixKittens', #{sanitize timestamp}),
      ('down', 'FixKittens', #{sanitize timestamp}),
      ('up', 'FixKittens', #{sanitize timestamp}),
      ('up', 'garbage', #{sanitize timestamp}),
      ('down', 'garbage', #{sanitize timestamp})
      SQL
    end

    it "should have the correct datafix statuses" do
      migration.up
      expect(Datafix::DatafixStatus.find_by(version: '1')).to be
    end
  end
end
