require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_controllers'

describe ComponentsController do

  it_behaves_like "a DulHydra controller"

  context "datastream methods" do
    let(:component) { FactoryGirl.create(:component_with_content_has_apo) }
    let(:user) { FactoryGirl.create(:reader) }
    before { sign_in user }
    after { sign_out user }
    after(:all) do
      user.delete
      component.admin_policy.delete
      component.delete
    end

    context "#datastreams" do
      subject { get :datastreams, :id => component }
      it "should render the 'datastreams' template" do
        expect(subject).to render_template(:datastreams)
      end
    end

    context "#datastream" do
      subject { get :datastream, :id => component, :dsid => "DC" }
      it "should render the 'datastream' template" do
        expect(subject).to render_template(:datastream)
      end
    end

    context "#datastream_content" do
      subject { get :datastream_content, :id => component, :dsid => "content" }
      it { should be_successful }
    end

  end

end
