require "migration_helper"

module DulHydra::Migration
  RSpec.describe OriginalFilename do

    subject { described_class.new(mover) }
    let(:mover) { double(target: target) }
    let(:target) { Component.new }

    describe "when legacy original filename is set on target" do
      before {
        target.legacy_original_filename = "foo.xml"
      }
      it "sets the value of original_name on the content file" do
        expect { subject.migrate }.to change(target.content, :original_name).from(nil).to("foo.xml")
      end
      it "removes the legacy original filename from target" do
        expect { subject.migrate }.to change(target, :legacy_original_filename).from("foo.xml").to(nil)
      end
    end

  end
end
