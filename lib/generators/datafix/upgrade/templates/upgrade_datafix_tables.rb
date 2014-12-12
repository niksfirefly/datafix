class UpgradeDatafixTables < ActiveRecord::Migration
  class DatafixLog < ActiveRecord::Base; end
  class DatafixStatus < ActiveRecord::Base; end

  def self.up
    create_table :datafix_statuses do |t|
      t.string :script
      t.string :direction
      t.timestamps null: false
    end

    add_index :datafix_statuses, :script, unique: true
    rename_table :datafix_log, :datafix_logs

    DatafixLog.select(:script).uniq.map(&:script).each do |script|
      log_entry = DatafixLog.where(script: script).order('timestamp DESC, id DESC').first
      DatafixStatus.create!(script: script, direction: log_entry.direction, updated_at: log_entry.timestamp)
    end
  end

  def self.down
    drop_table :datafix_statuses
    rename_table :datafix_logs, :datafix_log
  end
end

