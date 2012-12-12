require 'spec_helper'

shared_examples "a DulHydra controller" do

  def object_class
    Object.const_get(described_class.to_s.sub("Controller", "").singularize)
  end

  def object_instance_symbol
    object_class.to_s.downcase.to_sym
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
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }
      after { sign_out user }
      it { should be_successful }
    end
  end

  context "#create" do
    let(:user) { FactoryGirl.create(:user) }
    after(:all) { user.delete }
    subject { post :create, object_instance_symbol => {title: "Test Object", identifier: "foobar123"} }
    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user" do
      before { sign_in user }
      after { sign_out user }
      it "redirects to the show action" do
        expect(subject).to redirect_to(:action => :show, 
                                       :id => assigns(object_instance_symbol).id)
      end
    end
  end

  context "#show" do

    let!(:object) { object_class.create }
    let(:user) { FactoryGirl.create(:user) }

    after(:each) { object.delete }
    after(:all) { user.delete }

    subject { get :show, :id => object }

    context "publicly readable object" do
      let(:policy) { FactoryGirl.create(:public_read_policy) }
      after(:all) { policy.delete }
      context "controlled by permissions" do
        before do
          object.permissions = [{type: "group", name: "public", access: "read"}]
          object.save!
        end
        it { should be_successful }
      end
      context "controlled by policy" do
        before do
          object.admin_policy = policy
          object.save!
        end
        it { should be_successful }
      end
    end

    context "restricted read object" do
      let(:policy) { FactoryGirl.create(:registered_read_policy) }
      after(:all) { policy.delete }
      context "controlled by permissions" do
        before do
          object.permissions = [{type: "group", name: "registered", access: "read"}]
          object.save!
        end
        context "anonymous user" do
          its(:response_code) { should eq(403) }
        end
        context "authenticated user" do
          before { sign_in user }
          after { sign_out user }
          it { should be_successful }
        end
      end
      context "controlled by policy" do
        before do
          object.admin_policy = policy
          object.save!
        end
        context "anonymous user" do
          its(:response_code) { should eq(403) }
        end
        context "authenticated user" do
          before { sign_in user }
          after { sign_out user }
          it { should be_successful }
        end
      end
    end

  end

  context "#edit" do

    let!(:object) { object_class.create }
    let(:user) { FactoryGirl.create(:user) }

    after(:each) { object.delete }
    after(:all) { user.delete }

    subject { get :edit, :id => object }

    context "a permissions-controlled object" do
      context "by an anonymous user" do
        before do
          object.permissions = [{type: "group", name: "editors", access: "edit"}]
          object.save!
        end
        its(:response_code) { should eq(403) }
      end
      context "by an authenticated user" do
        before { sign_in user }
        after { sign_out user }
        context "not having edit permission" do
          before do
            object.permissions = [{type: "group", name: "editors", access: "edit"}]
            object.save!
          end
          its(:response_code) { should eq(403) }
        end
        context "having edit permission" do
          before do
            object.permissions = [{type: "person", name: user.email, access: "edit"}]
            object.save!
          end
          it { should be_successful }
        end
      end
    end

    context "a policy-governed object" do
      before do
        object.admin_policy = policy
        object.save!
      end
      after { policy.delete }
      context "by an anonymous user" do
        let(:policy) { FactoryGirl.create(:group_edit_policy) }
        its(:response_code) { should eq(403) }
      end
      context "by an authenticated user" do
        before { sign_in user }
        after { sign_out user }
        context "not having edit permission" do
          let(:policy) { FactoryGirl.create(:group_edit_policy) }
          its(:response_code) { should eq(403) }
        end
        context "having edit permission" do
          let(:policy) { FactoryGirl.create(:admin_policy) }
          before do
            policy.default_permissions = [{type: "person", name: user.email, access: "edit"}]
            policy.save!
          end
          it { should be_successful }
        end
      end
    end

  end # edit

  context "#update" do    
    subject { put :update, :id => @object }
  end

  context "#destroy" do
    subject { delete :destroy, :id => @object }
  end


end
