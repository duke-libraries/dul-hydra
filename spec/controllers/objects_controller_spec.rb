require 'spec_helper'

shared_examples "a newly created object" do
  it { should be_persisted }
  its(:edit_users) { should include(user.to_s) }
  it "should have an event log entry for the create action" do
    EventLog.where(object_identifier: subject.pid, user: user, model: subject.class.to_s, action: "create").count.should == 1
  end
end

shared_examples "a newly created object having preservation events" do
  it_behaves_like "a newly created object"
  its(:preservation_events) { should have(1).items }
end

describe ObjectsController, objects: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  after { user.destroy }

  describe "create actions" do
    before do
      DulHydra.creatable_models = ["AdminPolicy", "Collection", "Attachment"]
      controller.current_ability.can(:create, DulHydra.creatable_models.collect {|m| m.constantize})
    end

    describe "#new", descriptive_metadata: true do
      context "Collection" do
        subject { get :new, :type => "Collection" }
        it { should render_template("new") }
      end
      context "AdminPolicy" do
        subject { get :new, :type => "AdminPolicy" }
        it { should render_template("new") }
      end
      context "Attachment", attachments: true do
        subject { get :new, type: "Attachment", attached_to_id: attach_to.pid }
        let(:attach_to) { FactoryGirl.create(:collection) }
        after { attach_to.destroy }
        context "user can add attachments to object" do
          before { controller.current_ability.can(:add_attachment, attach_to) }
          it { should render_template("new") }
        end
        context "user cannot add attachments to object" do
          before { controller.current_ability.cannot(:add_attachment, attach_to) }
          its(:response_code) { should == 403 }
        end
      end # Attachment
    end

    describe "#create", descriptive_metadata: true do
      after { ActiveFedora::Base.destroy_all }
      context "Collection" do
        subject { assigns(:object) }
        let(:admin_policy) { FactoryGirl.create(:admin_policy) }
        before { post :create, type: 'Collection', object: {title: ['New Collection']}, admin_policy_id: admin_policy.pid }
        it_behaves_like "a newly created object having preservation events"
      end
      context "Attachment", attachments: true do
        let(:attach_to) { FactoryGirl.create(:collection) }
        context "user can add attachments to object" do
          subject { assigns(:object) }
          before do
            controller.current_ability.can(:add_attachment, attach_to)
            post :create, type: 'Attachment', object: {title: "Attachment"}, attached_to_id: attach_to.pid, content: fixture_file_upload('sample.docx') 
          end
          it_behaves_like "a newly created object having preservation events"
          its(:admin_policy) { should == attach_to.admin_policy }
          its(:source) { should == ["sample.docx"] }
          its(:attached_to) { should == attach_to }
        end
        context "user cannot add attachments to object" do
          subject { post :create, type: 'Attachment', object: {title: "Attachment"}, attached_to_id: attach_to.pid, content: fixture_file_upload('sample.docx') }
          before { controller.current_ability.cannot(:add_attachment, attach_to) }
          its(:response_code) { should == 403 }
        end
      end
      context "AdminPolicy" do
        subject { assigns(:object) }
        before { post :create, type: 'AdminPolicy', object: {title: ['New Collection']} }
        it_behaves_like "a newly created object"
        its(:read_groups) { should include("registered") }
      end
    end # create
  end # new / create

  describe "read and update actions" do
    let(:object) { FactoryGirl.create(:test_model) }
    after { object.destroy }

    describe "#show", descriptive_metadata: true do
      subject { get :show, :id => object }
      context "user can read" do
        before do
          object.read_users = [user.user_key]
          object.save!
        end
        it { should render_template('show') }
      end
      context "user cannot read" do
        before { controller.current_ability.cannot(:read, object) }
        its(:response_code) { should == 403 }
      end
    end

    describe "#edit", descriptive_metadata: true do
      subject { get :edit, :id => object }
      context "user can edit" do
        before { controller.current_ability.can(:edit, object) }
        it { should render_template('records/edit') }
      end
      context "user cannot edit" do
        before { controller.current_ability.cannot(:edit, object) }
        its(:response_code) { should == 403 }
      end
    end

    describe "#update", descriptive_metadata: true do
      context "user can edit" do
        before do
          object.edit_users = [user.user_key]
          object.save!
          put :update, :id => object, :object => {:title => ["Updated"]}
        end
        it "should redirect to the descriptive metadata tab of the show page" do
          response.should redirect_to(record_path(object))
        end
        it "should update the object" do
          object.reload
          object.title.should == ["Updated"]
        end
        it "should create an event log entry for the update action" do
          object.event_logs.count.should == 1
        end
      end
      context "user cannot edit" do
        subject { put :update, :id => object, :object => {:title => ["Updated"]} }
        before { controller.current_ability.cannot(:edit, object) }
        its(:response_code) { should == 403 }
      end
    end
  end

  describe "#upload" do
    let(:object) { FactoryGirl.create(:test_model_omnibus) }
    after { object.destroy }
    context "GET method" do
      subject { get :upload, id: object }
      context "user can upload" do
        before { controller.current_ability.can(:upload, object) }
        it { should render_template("upload") }
      end
      context "user cannot upload" do
        before { controller.current_ability.cannot(:upload, object) }
        its(:response_code) { should == 403 }
      end
    end
    context "PATCH method" do
      context "user can upload" do
        before { controller.current_ability.can(:upload, object) }
        it "should redirect to the show page" do
          patch :upload, id: object, content: fixture_file_upload('sample.docx')
          response.should redirect_to(object_path(object))
        end
        it "should update the object" do
          patch :upload, id: object, content: fixture_file_upload('sample.pdf')
          assigns(:object).source.should == ["sample.pdf"]
          assigns(:object).content.size.should == 83777
        end
      end
      context "user cannot upload" do
        subject { patch :upload, id: object, content: fixture_file_upload('sample.docx') }
        before { controller.current_ability.cannot(:upload, object) }
        its(:response_code) { should == 403 }
      end
    end
  end

end
