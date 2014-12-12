require "spec_helper"
require 'generators/datafix/upgrade/templates/update_datafix_statuses'

describe "Datafix Migrations" do
  def sanitize(value)
    ActiveRecord::Base.connection.quote(value)
  end

  describe "migrating from previous Datafix installation" do
    let(:migration) { UpdateDatafixStatuses.new }
    let(:timestamp) { '2014-10-05 05:00' }

    before do
      # Seed log with events but leave statuses empty.
      DatafixLog.connection.execute(<<-SQL)
      INSERT INTO datafix_logs (direction, script, timestamp)
      VALUES
      ('up', 'uniquescript', #{sanitize timestamp}),
      ('down', 'uniquescript', #{sanitize timestamp}),
      ('up', 'uniquescript', #{sanitize timestamp}),
      ('up', 'garbage', #{sanitize timestamp}),
      ('down', 'garbage', #{sanitize timestamp})
      SQL
    end

    it "should have the correct datafix statuses" do
      expect(DatafixStatus.count).to eq 0
      expect {
        migration.up
      }.to change { DatafixStatus.count }.by 2

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
