require 'spec_helper'

describe "targets/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:collection_has_target_public_read) }
  before { visit targets_path(object) }
  after do
    object.targets.each { |t| t.delete }
    object.reload # work around https://github.com/projecthydra/active_fedora/issues/36
    object.delete
  end
  it "should link to the collection and list the targets associated with the object" do
    expect(subject).to have_link(object.title_display, :href => catalog_path(object))
    object.targets.each do |target|
      expect(subject).to have_link(target.title_display, :href => catalog_path(target))
      expect(subject).to have_content(target.pid)
      target.identifier.each do |identifier|
        expect(subject).to have_content(identifier)
      end
    end
  end
end
