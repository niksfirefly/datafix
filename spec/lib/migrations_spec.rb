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
      ('up', 'uniquescript', #{sanitize timestamp}),
      ('down', 'uniquescript', #{sanitize timestamp}),
      ('up', 'uniquescript', #{sanitize timestamp}),
      ('up', 'garbage', #{sanitize timestamp}),
      ('down', 'garbage', #{sanitize timestamp})
      SQL
    end

    it "should have the correct datafix statuses" do
      migration.up
      expect(DatafixStatus.count).to eq 2

      unique = DatafixStatus.find_by(script: 'uniquescript')
      expect(unique.direction).to eq 'up'
      expect(unique.script).to eq 'uniquescript'
      expect(unique.updated_at).to eq timestamp

      garbage = DatafixStatus.find_by(script: 'garbage')
      expect(garbage.direction).to eq 'down'
      expect(garbage.script).to eq 'garbage'
      expect(garbage.updated_at).to eq timestamp
    end
  end
end
