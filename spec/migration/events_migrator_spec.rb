require "migration_helper"

module DulHydra::Migration
  RSpec.describe EventsMigrator do

    subject { described_class.new(mover) }

    let(:mover) { double(source: source, target: target) }
    let(:source_pid) { "test:1" }
    let(:target_id) { "ab/cd/abcdefgh"}
    let(:source) { double(pid: source_pid) }
    let(:target) { double(id: target_id) }
    let(:user) { FactoryGirl.create(:user) }
    let(:event_dt_tm) { Time.new(2016, 01, 07, 13, 54, 0) }
    let(:event_attributes) do
      { event_date_time: event_dt_tm,
        user_id: user.id,
        type: "Ddr::Events::CreationEvent",
        software: "ddr-models 2.3.2",
        comment: "event comment",
        summary: "event summary",
        outcome: Ddr::Events::Event::FAILURE,
        detail: "event detail",
        exception: "event exception",
        user_key: user.user_key
      }
    end
    let(:event) { Ddr::Events::Event.new(event_attributes.merge({ pid: source_pid })) }

    describe "when object has events" do
      before do
        event.save!
        event.reload
      end
      it "updates the event pid" do
        subject.migrate
        event.reload
        expect(event.pid).to eq(target_id)
      end
      it "does not change other event attributes" do
        subject.migrate
        event.reload
        event_attributes.each do |key, value|
          expect(event.send(key)).to eq(value)
        end
      end
    end

  end
end
