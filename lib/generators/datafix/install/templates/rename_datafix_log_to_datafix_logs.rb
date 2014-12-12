class RenameDatafixLogToDatafixLogs < ActiveRecord::Migration
  def self.change
    rename_table :datafix_log, :datafix_logs
  end
end

