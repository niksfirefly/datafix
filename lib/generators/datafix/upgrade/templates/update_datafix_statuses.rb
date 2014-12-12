class UpdateDatafixStatuses < ActiveRecord::Migration
  class DatafixStatus < ActiveRecord::Base; end
  class DatafixLog < ActiveRecord::Base; end

  def self.up
    DatafixLog.select(:script).uniq.map(&:script).each do |script|
      log_entry = DatafixLog.where(script: script).order('timestamp DESC, id DESC').first
      DatafixStatus.create!(script: script, direction: log_entry.direction, updated_at: log_entry.timestamp)
    end
  end

  def self.down
    execute("DELETE FROM datafix_statuses")
  end
end
