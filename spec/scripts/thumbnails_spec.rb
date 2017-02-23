require 'spec_helper'

module DulHydra::Scripts

  describe Thumbnails do

    let(:item) { FactoryGirl.create(:item, :member_of_collection) }
    let(:component) { Component.create }
    let(:collection) { item.collection }
    let(:thumbnails_script) { DulHydra::Scripts::Thumbnails.new(collection.pid) }
    let(:thumbnail) { fixture_file_upload('target.png') }
    let(:thumbnail_checksum) { Ddr::Utils.digest(File.read(thumbnail), 'SHA-1') }

    before do
      item.children << component
      item.save!
    end

    context "thumbnail does not exist" do

      context "child has thumbnail" do
        before do
          component.thumbnail.content = thumbnail
          component.save!
        end
        it "should populate the thumbnail datastream from the child thumbnail" do
          thumbnails_script.execute
          item.reload
          expect(item.thumbnail.checksum).to eq(thumbnail_checksum)
        end
      end

      context "child does not have thumbnail" do
        it "should not populate the thumbnail datastream" do
          thumbnails_script.execute
          item.reload
          expect(item.thumbnail).to_not have_content
        end
      end

    end

    context "thumbnail already exists" do
      let(:item_thumbnail) { StringIO.new("awesome image") }
      before do
        component.thumbnail.content = thumbnail
        component.save!
        item.thumbnail.content = item_thumbnail
        item.save!
      end
      it "should not alter the existing thumbnail" do
        thumbnails_script.execute
        item.reload
        expect(item.thumbnail.content).to eq("awesome image")
      end
    end

  end

end
