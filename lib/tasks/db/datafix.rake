namespace :db do
  desc "Run the 'up' on all unrun datafixes"
  task :datafix => :environment do
    if ENV['NAME'].present?
      Rake::Task["db:datafix:up"].invoke
    else
      class DatafixStatus < ActiveRecord::Base; end

      Dir.glob(Rails.root.join("db/datafixes/*.rb")).each do |path|
        script = script_from_name(File.basename(path))

        if DatafixStatus.where(script: script, direction: "up").blank?
          require path
          klass_from_name(File.basename(path)).migrate('up')
        end
      end
    end
  end

  namespace :datafix do
    desc "Run the 'up' on the passed datafix"
    task :up => :environment do
      name = ENV['NAME']
      raise 'NAME required' if name.blank?

      require path_from_name(name)
      klass_from_name(name).migrate('up')
    end

    desc "Run the 'down' operation on the passed datafix"
    task :down => :environment do
      name = ENV['NAME']
      raise 'NAME required' if name.blank?

      require path_from_name(name)
      klass_from_name(name).migrate('down')
    end

    desc "Show the statuses of all datafixes"
    task :status => :environment do
      puts "\ndatabase: #{ActiveRecord::Base.connection_config[:database]}\n\n"
      puts "#{'Status'.center(8)}  #{'Last Run'.ljust(24)}  Datafix Name"
      puts "-" * 60

      class DatafixStatus < ActiveRecord::Base; end
      DatafixStatus.order(:updated_at).each do |status|
        puts "#{status.direction.center(8)} #{status.updated_at.to_s.ljust(24)} #{status.script}"
      end
      puts
    end
  end

  private

  def script_from_name(name)
    name.split(File::SEPARATOR).last.gsub(/^\d+_/, '').gsub(/.rb$/, '').camelize
  end

  def klass_from_name(name)
    "Datafixes::#{script_from_name(name)}".constantize
  end

  def path_from_name(name)
    unless name =~ %r(^db/datafixes/)
      name = name.underscore
      name = Dir.glob("db/datafixes/*_#{name}.rb").first
    end
    Rails.root.join(name)
  end
end
