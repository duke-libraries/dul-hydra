require 'spec_helper'

shared_examples "a DulHydra controller" do

  def object_class
    Object.const_get(described_class.to_s.sub("Controller", "").singularize)
  end

  def object_instance_symbol
    object_class.to_s.downcase.to_sym
  end

  before(:all) do
    @registered_user = FactoryGirl.create(:user)
    @editor = FactoryGirl.create(:editor)
    @public_read_policy = FactoryGirl.create(:public_read_policy)
  end

  before(:each) do
    @object = object_class.create
  end

  after(:all) do
    @registered_user.delete
    @editor.delete
    @public_read_policy.delete
    object_class.find_each { |o| o.delete }
  end

  context "#index" do
    subject { get :index }
    it "renders the index template" do
      expect(subject).to render_template(:index)
    end
  end

  context "#new" do
    subject { get :new }
    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user" do
      before { sign_in @registered_user }
      after { sign_out @registered_user }
      it { should be_successful }
    end
  end

  context "#create" do
    subject { post :create, object_instance_symbol => {title: "Test Object", identifier: "foobar123"} }
    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user" do
      before { sign_in @registered_user }
      after { sign_out @registered_user }
      it "redirects to the show action" do
        expect(subject).to redirect_to(:action => :show, 
                                       :id => assigns(object_instance_symbol).id)
      end
    end
  end

  context "#show" do
    subject { get :show, :id => @object }
    context "publicly readable object" do
      context "controlled by permissions" do
        before do
          @object.read_groups = ["public"]
          @object.save!
        end
        it { should be_successful }
      end
      context "controlled by policy" do
        before do
          @object.admin_policy = @public_read_policy
          @object.save!
        end
        it { should be_successful }
      end
    end
    context "restricted read object" do
      before do
        @object.read_groups = ["registered"]
        @object.save!
      end
      context "anonymous user" do
        its(:response_code) { should eq(403) }
      end
      context "authenticated user" do
        before { sign_in @registered_user }
        after { sign_out @registered_user }
        it { should be_successful }
      end
    end
  end

  context "#edit" do
    subject { get :edit, :id => @object }
    before do
      @object.read_groups = ["public"]
      @object.edit_groups = [DulHydra::Permissions::EDITOR_GROUP_NAME]
      @object.save!
    end
    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user not having edit permission" do
      before { sign_in @registered_user }
      after { sign_out @registered_user }
      its(:response_code) { should eq(403) }
    end
    context "authenticated user having edit permission" do
      before { sign_in @editor }
      after { sign_out @editor }
      it { should be_successful }
    end
  end

  context "#update" do    
    subject { put :update, :id => @object }
  end

  context "#destroy" do
    subject { delete :destroy, :id => @object }
  end


end
