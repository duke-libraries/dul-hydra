def object_symbol
  object_model.underscore.to_sym
end

def object_model
  described_class.to_s.sub("Controller", "").singularize
end

def object_class
  object_model.constantize
end

def update_metadata
  put :update, id: object, descMetadata: {title: ["Updated"]}, comment: "Just for fun!"
end

def update_admin_metadata
  patch :admin_metadata, id: object, adminMetadata: {local_id: "foobar"}, comment: "This is serious!"
end

shared_examples "a repository object controller" do

  it "should add access controls to solr params" do
    expect(described_class.solr_search_params_logic).to include(:add_access_controls_to_solr_params)
  end

  describe "#new" do
    context "when the user can create an object of this type" do
      before { controller.current_ability.can(:create, object_class) }
      it "should render the new template" do
        new_object.call
        expect(response).to render_template(:new)
      end
    end
    context "when the user cannot create an object of this type" do
      before { controller.current_ability.cannot(:create, object_class) }
      it "should be unauthorized" do
        new_object.call
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    context "when the user can create an object of this type" do
      before { controller.current_ability.can(:create, object_class) }
      it "should persist the object" do
        expect{ create_object.call }.to change{ object_class.count }.by(1)
      end
      it "should not save an empty string metadata element" do
        create_object.call
        expect(assigns(:current_object).description).to be_blank
      end
      it "should grant roles to the creator" do
        expect_any_instance_of(object_class).to receive(:grant_roles_to_creator).with(user)
        create_object.call
      end
      it "should redirect after creating the new object" do
        expect(controller).to receive(:after_create_redirect).and_call_original
        create_object.call
        expect(response).to be_redirect
      end
    end
    context "when the user cannot create objects of this type" do
      before { controller.current_ability.cannot(:create, object_class) }
      it "should be unauthorized" do
        create_object.call
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#edit" do
    let(:object) { FactoryGirl.create(object_symbol) }
    context "when the user can edit the object" do
      before do
        object.roles.grant type: "Editor", agent: user
        object.save!
      end
      it "should render the edit template" do
        expect(get :edit, id: object).to render_template 'edit'
      end
    end
    context "when the user cannot edit the object" do
      it "should be unauthorized" do
        get :edit, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#update" do
    let(:object) { FactoryGirl.create(object_symbol) }
    context "when the user can edit" do
      before do
        object.roles.grant type: "Editor", agent: user
        object.save!
      end
      it "should redirect to the descriptive metadata tab of the show page" do
        update_metadata
        expect(response).to redirect_to(action: "show", id: object, tab: "descriptive_metadata")
      end
      it "should update the object" do
        expect{ update_metadata; object.reload }.to change { object.descMetadata }
      end
      it "should create an update event" do
        expect{ update_metadata }.to change { object.update_events.count }.by(1)
      end
      it "should record the comment in the update event" do
        update_metadata
        expect(object.update_events.last.comment).to eq "Just for fun!"
      end
      it "should add an action-specific summary to the event" do
        update_metadata
        expect(object.update_events.last.summary).to eq "Descriptive metadata updated"
      end
    end
    context "when the user cannot edit" do
      it "should be unauthorized" do
        update_metadata
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#show" do
    let(:object) { FactoryGirl.create(object_symbol) }
    context "when the user can read the object" do
      before do
        object.roles.grant type: "Viewer", agent: user
        object.save!
      end
      it "should render the show template" do
        expect(get :show, id: object).to render_template(:show)
      end
    end
    context "when the user cannot read the object" do
      it "should be unauthorized" do
        get :show, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#roles" do
    let(:object) { FactoryGirl.create(object_symbol) }
    context "when the user can grant roles" do
      before do
        object.roles.grant type: "Curator", agent: user
        object.save!
      end
      it "should render the roles template" do
        expect(get :roles, id: object).to render_template(:roles)
      end
    end
    context "when the user cannot grant roles" do
      it "should be unauthorized" do
        get :roles, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#admin_metadata" do
    let(:object) { FactoryGirl.create(object_symbol) }
    describe "GET" do
      context "when the user can update admin metadata" do
        before do
          object.roles.grant type: "Editor", agent: user
          object.save!
        end
        it "should render the admin_metadata template" do
          expect(get :admin_metadata, id: object).to render_template(:admin_metadata)
        end
      end
      context "when the user cannot update admin metadata" do
        it "should be unauthorized" do
          get :admin_metadata, id: object
          expect(response.response_code).to eq(403)
        end
      end
    end
    describe "PATCH" do
      context "when the user can update admin metadata" do
        before do
          object.roles.grant type: "Editor", agent: user
          object.save!
        end
        it "should redirect to the admin metadata tab of the show page" do
          update_admin_metadata
          expect(response).to redirect_to(action: "show", id: object, tab: "admin_metadata")
        end
        it "should update the object" do
          expect{ update_admin_metadata; object.reload }.to change { object.adminMetadata }
        end
        it "should create an update event" do
          expect{ update_admin_metadata }.to change { object.update_events.count }.by(1)
        end
        it "should record the comment in the update event" do
          update_admin_metadata
          expect(object.update_events.last.comment).to eq "This is serious!"
        end
        it "should add an action-specific summary to the event" do
          update_admin_metadata
          expect(object.update_events.last.summary).to eq "Administrative metadata updated"
        end
      end
      context "when the user cannot update admin metadata" do
        it "should be unauthorized" do
          update_admin_metadata
          expect(response.response_code).to eq(403)
        end
      end
    end
  end

end

