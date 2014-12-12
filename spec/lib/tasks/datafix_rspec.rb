require "spec_helper"
require "rake"
require "rails/generators"
require "generators/datafix/datafix_generator"

describe "datafix rake tasks" do
  let(:datafix1) { "fix_generated_salmons" }
  let(:datafix2) { "fix_generated_tuna" }

  def create_fix(fix_name)
    Rails::Generators.invoke("datafix", [fix_name])
  end

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "tasks/db/datafix"
    Rake::Task.define_task(:environment)

    @old_path = Dir.pwd
    Dir.chdir(Rails.root)
    create_fix("fix_generated_salmons")
    create_fix("fix_generated_tuna")

    Dir.glob(Rails.root.join("db/datafixes/*.rb")).each do |path|
      require path
    end
  end

  after(:each) do
    DatafixStatus.delete_all
    Rake::Task["db:datafix"].reenable
    Rake::Task["db:datafix:up"].reenable
    Rake::Task["db:datafix:down"].reenable
  end

  after(:all) do
    Dir.chdir(@old_path)
    @old_path = nil
  end

  describe "datafix" do
    it "runs the up migration for all datafixes" do
      expect(Datafixes::FixGeneratedSalmons).to receive(:up)
      expect(Datafixes::FixGeneratedTuna).to receive(:up)
      @rake["db:datafix"].invoke
    end

    context "when one has already been run" do
      before { Datafixes::FixGeneratedSalmons.migrate('up') }

      it "should only run ones that aren't up" do
        expect(Datafixes::FixGeneratedSalmons).to_not receive(:up)
        expect(Datafixes::FixGeneratedTuna).to receive(:up)
        @rake["db:datafix"].invoke
      end
    end
  end

  describe "up" do
    it "runs the migration" do
      expect(Datafixes::FixGeneratedSalmons).to receive(:up)
      ENV['NAME'] = datafix1
      @rake["db:datafix:up"].invoke
    end
  end

  describe "down" do
    it "runs the migration" do
      expect(Datafixes::FixGeneratedSalmons).to receive(:down)
      ENV['NAME'] = datafix1
      @rake["db:datafix:down"].invoke
    end
  end
end
