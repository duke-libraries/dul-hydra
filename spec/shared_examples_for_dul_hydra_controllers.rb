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
      after do
        sign_out user
        user.delete
      end
      it { should be_successful }
    end
  end

  context "#create" do
    subject { post :create, object_instance_symbol => {title: "Test Object", identifier: "foobar123"} }

    context "anonymous user" do
      its(:response_code) { should eq(403) }
    end
    context "authenticated user" do
      let!(:user) { FactoryGirl.create(:user) }
      before { sign_in user }
      after do
        sign_out user
        user.delete
        object_class.find(assigns(object_instance_symbol).id).delete
      end
      it "redirects to the show action" do
        expect(subject).to redirect_to(:action => :show, 
                                       :id => assigns(object_instance_symbol).id)
      end
    end
  end

  context "#show" do
    subject { get :show, :id => object }

    let!(:object) { object_class.create }
    after { object.delete }

    context "publicly readable object" do
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
        after { policy.delete }
        let(:policy) { FactoryGirl.create(:public_read_policy) }
        it { should be_successful }
      end
    end

    context "restricted read object" do
      context "controlled by permissions" do
        before do
          object.permissions = [{type: "group", name: "registered", access: "read"}]
          object.save!
        end
        context "anonymous user" do
          its(:response_code) { should eq(403) }
        end
        context "authenticated user" do
          let!(:user) { FactoryGirl.create(:user) }
          before { sign_in user }
          after do
            sign_out user
            user.delete
          end
          it { should be_successful }
        end
      end
      context "controlled by policy" do
        let!(:policy) { FactoryGirl.create(:registered_read_policy) }
        before do
          object.admin_policy = policy
          object.save!
        end
        after { policy.delete }
        context "anonymous user" do
          its(:response_code) { should eq(403) }
        end
        context "authenticated user" do
          let!(:user) { FactoryGirl.create(:user) }
          before { sign_in user }
          after do
            sign_out user
            user.delete
          end
          it { should be_successful }
        end
      end
    end

  end #show

  context "#edit" do
    subject { get :edit, :id => object }

    let!(:object) { object_class.create }
    after { object.delete }

    context "a permissions-controlled object" do
      before do
        object.permissions = permissions
        object.save!
      end
      context "by an anonymous user" do
        let(:permissions) { [{type: "group", name: "public", access: "read"}] }
        its(:response_code) { should eq(403) }
      end
      context "by an authenticated user" do
        before { sign_in user }
        after do
          sign_out user
          user.delete
        end
        context "not having edit permission" do
          let(:user) { FactoryGirl.create(:user) }
          let(:permissions) { [{type: "user", name: user.email, access: "read"}] }
          its(:response_code) { should eq(403) }
        end
        context "having edit permission" do
          let(:user) { FactoryGirl.create(:user) }
          let(:permissions) { [{type: "user", name: user.email, access: "edit"}] }
          it { should be_successful }
        end
      end
    end

    context "a policy-governed object" do
      let!(:policy) { FactoryGirl.create(:admin_policy) }
      before do
        policy.default_permissions = default_permissions
        policy.save!
        object.admin_policy = policy
        object.save!
      end
      after { policy.delete }
      context "by an anonymous user" do
        let(:default_permissions) { [{type: "group", name: "public", access: "read"}] }
        its(:response_code) { should eq(403) }
      end
      context "by an authenticated user" do
        before { sign_in user }
        after do
          sign_out user
          user.delete
        end
        context "not having edit permission" do
          let(:user) { FactoryGirl.create(:user) }
          let(:default_permissions) { [{type: "user", name: user.email, access: "read"}] }
          its(:response_code) { should eq(403) }
        end
        context "having edit permission" do
          let(:user) { FactoryGirl.create(:user) }
          let(:default_permissions) { [{type: "user", name: user.email, access: "edit"}] }
          it { should be_successful }
        end
      end
    end

  end #edit

  context "#update" do    
    subject { put :update, :id => @object }
  end

  context "#destroy" do
    subject { delete :destroy, :id => @object }
  end


end
