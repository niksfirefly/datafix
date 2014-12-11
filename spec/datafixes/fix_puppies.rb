class Datafixes::FixPuppies < Datafix
  def self.up
    table_name = Puppy.table_name
    archive_table(table_name)
    execute %Q{ UPDATE #{table_name} SET fixed = 't'; }
  end

  def self.down
    table_name = Puppy.table_name
    revert_archive_table(table_name)
  end
end
