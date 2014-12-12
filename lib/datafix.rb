require "datafixes"
require "datafix/version"
require "datafix/railtie" if defined?(Rails)

class Datafix
  class << self
    DIRECTIONS = %w[up down]

    def migrate(direction)
      raise ArgumentError unless DIRECTIONS.include?(direction)

      ActiveRecord::Base.transaction do
        send(direction.to_sym)
        log_run(direction)
        log_status(direction)
      end
    end

    def up?
      response = execute("SELECT * FROM datafix_statuses WHERE script = #{quote script_name}");
      response.first && response.first["direction"] == "up"
    end

    private

    def log_run(direction)
      puts "migrating #{script_name} #{direction}"

      execute(<<-SQL)
      INSERT INTO datafix_logs
      (direction, script, timestamp)
      VALUES ('#{direction}', '#{script_name}', NOW())
      SQL
    end

    def log_status(direction)
      response = execute("SELECT * FROM datafix_statuses WHERE script = #{quote script_name}");
      if(response.count > 0)
        execute(<<-SQL)
        UPDATE datafix_statuses
        SET direction = #{quote direction}, updated_at = NOW()
        WHERE script = #{quote script_name}
        SQL
      else
        execute(<<-SQL)
        INSERT INTO datafix_statuses (direction, script, updated_at, created_at)
        VALUES (#{quote direction}, #{quote script_name}, NOW(), NOW())
        SQL
      end
    end

    def script_name
      @script_name ||= self.name.camelize.split('::').tap(&:shift).join('::').camelize
    end

    def connection
      @connection ||= ActiveRecord::Base.connection
    end

    def quote(value)
      connection.quote(value)
    end

    def execute(*args)
      connection.execute(*args)
    end

    def table_exists?(table_name)
      ActiveRecord::Base.connection.table_exists? table_name
    end

    def archive_table(table_name)
      log "Archive #{table_name} for Rollback" if self.respond_to?(:log)
      execute "CREATE TABLE archived_#{table_name} ( LIKE #{table_name} INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES )"
      execute "INSERT INTO archived_#{table_name} SELECT * FROM #{table_name}"
    end

    def revert_archive_table(table_name)
      log "Move old #{table_name} back" if self.respond_to?(:log)
      execute "TRUNCATE TABLE #{table_name}"
      execute "INSERT INTO #{table_name} SELECT * FROM archived_#{table_name}"
      execute "DROP TABLE archived_#{table_name}"
    end
  end
end
