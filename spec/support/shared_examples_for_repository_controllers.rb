def update_rights
  patch :permissions, id: object, permissions: {"discover" => ["group:public", "user:Sally", "user:Mitch"], "read" => ["group:registered", "user:Gil", "user:Ben"], "edit" => ["group:editors", "group:managers", "user:Rocky", "user:Gwen", "user:Teresa"]}, license: {"title" => "No Access", "description" => "No one can get to it", "url" => "http://www.example.com"}
end

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
  put :update, id: object, descMetadata: {title: ["Updated"]}
end

shared_examples "a repository object controller" do

  describe "#permissions" do
    let(:object) { FactoryGirl.create(object_symbol) }
    context "when the user has edit rights" do
      before do
        object.edit_users = [user.user_key]
        object.save
      end
      context "GET" do
        it "should display the rights" do
          expect(get :permissions, id: object).to render_template(:permissions)
        end
      end
      context "PATCH" do
        it "should update the permissions" do
          update_rights
          object.reload
          object.discover_groups.should == ["public"]
          object.read_groups.should == ["registered"]
          object.edit_groups.should == ["editors", "managers"]
          object.discover_users.should == ["Sally", "Mitch"]
          object.read_users.should == ["Gil", "Ben"]
          object.edit_users.should == ["Rocky", "Gwen", "Teresa"]
          object.license_title.should == "No Access"
          object.license_description.should == "No one can get to it"
          object.license_url.should == "http://www.example.com"
        end
        it "should redirect to the show view" do
          update_rights
          expect(response).to be_redirect
        end
        it "should create an update event" do
          expect { update_rights }.to change { object.update_events.count }.by(1)
        end
      end
    end
    context "when the user does not have edit rights" do
      context "GET" do
        it "should be unauthorized" do
          get :permissions, id: object
          expect(response.response_code).to eq(403)
        end
      end
      context "PATCH" do
        it "should be unauthorized" do
          update_rights
          expect(response.response_code).to eq(403)
        end
      end
    end
  end

  describe "#new" do
    context "when the user can create an object of this type" do
      before { controller.current_ability.can(:create, object_class) }
      it "should render the new template" do
        new_object.call
        expect(response).to render_template(:new)
      end
    end
    context "when the user cannot an object of this type" do
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
      it "should grant edit permission on the object to the user" do
        create_object.call
        expect(assigns(:current_object).edit_users).to include(user.user_key)
      end
      it "should record a creation event" do
        expect{ create_object.call }.to change { CreationEvent.count }.by(1)
      end
      it "should redirect to the edit page" do
        create_object.call
        expect(response).to redirect_to(action: 'edit', id: assigns(:current_object))
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
      before { controller.current_ability.can(:edit, object) }
      it "should render the edit template" do
        expect(get :edit, id: object).to render_template 'edit'
      end
    end
    context "when the user cannot edit the object" do
      before { controller.current_ability.cannot(:edit, object) }
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
        object.edit_users = [user.user_key]
        object.save
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
    end
    context "when the user cannot edit" do
      before { controller.current_ability.cannot(:edit, object) }
      it "should be unauthorized" do
        update_metadata
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#show" do
    let(:object) { FactoryGirl.create(object_symbol) }
    context "when the user can read the object" do
      before { controller.current_ability.can(:read, object) }
      it "should render the show template" do
        expect(get :show, id: object).to render_template(:show)
      end
    end
    context "when the user cannot read the object" do
      before { controller.current_ability.cannot(:read, object) }
      it "should be unauthorized" do
        get :show, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

end

