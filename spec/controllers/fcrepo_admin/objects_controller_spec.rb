require 'spec_helper'

describe FcrepoAdmin::ObjectsController do
  context "#preservation_events" do
    subject { get :preservation_events, :id => object, :use_route => 'fcrepo_admin' }
    let(:object) { FactoryGirl.create(:test_content_with_fixity_check) }
    after do 
      object.preservation_events.each { |pe| pe.delete }
      object.reload # work around https://github.com/projecthydra/active_fedora/issues/36
      object.delete
    end 
    it { should render_template(:preservation_events) }
  end
end
