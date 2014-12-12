class Datafix
  class DatafixStatusPresenter < Struct.new(:status, :direction, :version, :script_name)
    class << self
      def table_header
        "\ndatabase: #{ActiveRecord::Base.connection_config[:database]}\n\n" +
          "#{'Status'.center(8)}  #{'Datafix ID'.ljust(20)}  Datafix Name\n" +
          "-" * 50 + "\n"
      end

      def from_migration(migration)
        status = Datafix::DatafixStatus.find_by(version: migration.version.to_s)
        direction = status.present? ? 'up' : 'down'
        new(status, direction, migration.version, script_from_name(migration.filename))
      end

      private

      def script_from_name(name)
        name.split(File::SEPARATOR).last.gsub(/^\d+_/, '').gsub(/.rb$/, '').camelize
      end
    end

    def to_table_s
      "#{direction.center(8)} #{version.to_s.ljust(20)} #{script_name}"
    end
  end
end
