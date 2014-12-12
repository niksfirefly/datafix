class CreateDatafixTables < ActiveRecord::Migration
  def self.up
    create_table :datafix_logs do |t|
      t.string :direction
      t.string :script
      t.timestamp :timestamp
    end

    create_table :datafix_statuses do |t|
      t.string :version
    end

    add_index :datafix_statuses, :version, unique: true
  end

  def self.down
    drop_table :datafix_logs
    drop_table :datafix_statuses
  end
end

