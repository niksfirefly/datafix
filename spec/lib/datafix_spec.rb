require "spec_helper"

describe Datafix do
  let(:kitten_names) { %w[nyan hobbes stimpy tigger garfield] }
  let(:table_name) { Kitten.table_name }
  let(:archived_table_name) { "archived_#{table_name}" }

  before do
    kitten_names.each do |name|
      Kitten.create!(name: name)
    end
    expect(Kitten.where(fixed: true)).to be_empty
  end

  context "after running fix kittens up" do
    before do
      Datafixes::FixKittens.migrate('up')
    end

    it "fixes all kittens" do
      expect(Kitten.where(fixed: false)).to be_empty
    end

    it "creates a kittens archive table" do
      expect(Kitten.connection.table_exists?(archived_table_name)).to eq true
      expect(Kitten.connection.select_value("SELECT COUNT(*) FROM #{archived_table_name}").to_i).to eq kitten_names.size
    end

    it "updates the datafix log" do
      datafix_log = DatafixLog.last
      expect(datafix_log.direction).to eq 'up'
      expect(datafix_log.script).to eq 'FixKittens'
    end

    it "updates its datafix status" do
      datafix_status = DatafixStatus.last
      expect(datafix_status.direction).to eq 'up'
      expect(datafix_status.script).to eq 'FixKittens'
    end

    it "return true for up?" do
      expect(Datafixes::FixKittens.up?).to be_truthy
    end

    context "after running fix kittens down" do
      before do
        Datafixes::FixKittens.migrate('down')
      end

      it "unfixes the kittens" do
        expect(Kitten.where(fixed: true)).to be_empty
      end

      it "removes the kittens archive table" do
        expect(Kitten.connection.table_exists?("archived_kittens")).to eq false
      end

      it "updates the datafix log" do
        datafix_log = DatafixLog.last
        expect(datafix_log.direction).to eq 'down'
        expect(datafix_log.script).to eq 'FixKittens'
      end

      it "updates its datafix status" do
        expect(DatafixStatus.count).to eq 1
        datafix_status = DatafixStatus.first
        expect(datafix_status.direction).to eq 'down'
        expect(datafix_status.script).to eq 'FixKittens'
      end

      it "return false for up?" do
        expect(Datafixes::FixKittens.up?).to be_falsy
      end
    end
  end
end
