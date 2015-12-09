require "migration_helper"

module DulHydra::Migration
  RSpec.describe MultiresImageFilePath do

    subject { described_class.new(mover) }

    let(:source) { ::Rubydora::DigitalObject.new("duke:1") }
    let(:target) { Component.new }
    let(:mover) { double(source: source, target: target) }
    let(:datastream) { ::Rubydora::Datastream.new(nil, nil, {}, {controlGroup: "E"}) }

    describe "when source has a multiresImage datastream" do
      before {
        allow(source).to receive(:datastreams) { {"multiresImage" => datastream} }
        allow(datastream).to receive(:dsLocation) { "file:/dev/null" }
      }
      it "sets the target property" do
        expect { subject.migrate }.to change(target, :multires_image_file_path).from(nil).to("file:/dev/null")
      end
    end

    describe "when source does not have a multiresImage datastream" do
      before {
        allow(source).to receive(:datastreams) { {"other" => datastream} }
      }
      it "does not set the target property" do
        expect { subject.migrate }.not_to change(target, :multires_image_file_path)
      end
    end

  end
end
