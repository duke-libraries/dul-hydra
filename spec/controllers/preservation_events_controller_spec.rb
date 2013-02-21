require 'spec_helper'

describe PreservationEventsController do
  context "#index" do
    subject { get :index, :object_id => object }
    let(:object) { FactoryGirl.create(:test_content_with_fixity_check) }
    after do 
      object.preservation_events.each { |pe| pe.delete }
      object.reload # work around https://github.com/projecthydra/active_fedora/issues/36
      object.delete
    end 
    it { should render_template(:index) }
  end
end