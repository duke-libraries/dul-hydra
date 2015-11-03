shared_examples "a repository object controller" do

  it "adds :apply_gated_discovery to search params logic" do
    expect(described_class.search_params_logic).to include(:apply_gated_discovery)
  end

  describe "#show" do
    describe "when the user can read the object" do
      before do
        object.roles.grant type: "Viewer", agent: user
        object.save!
      end
      it "renders the show template" do
        expect(get :show, id: object).to render_template(:show)
      end
    end
    describe "when the user cannot read the object" do
      it "is unauthorized" do
        get :show, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#edit" do
    describe "when the user can edit the object" do
      before do
        object.roles.grant type: "MetadataEditor", agent: user
        object.save!
      end
      it "should render the edit template" do
        expect(get :edit, id: object).to render_template 'edit'
      end
    end
    describe "when the user cannot edit the object" do
      before { controller.current_ability.cannot(:edit, object) }
      it "should be unauthorized" do
        get :edit, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#update" do
    describe "when the user can edit" do
      before do
        object.roles.grant type: "MetadataEditor", agent: user
        object.save!
      end
      it "redirects to the descriptive metadata tab of the show page" do
        put :update, id: object, descMetadata: {title: ["Updated"]}, comment: "Just for fun!"
        expect(response).to redirect_to(action: "show", id: object, tab: "descriptive_metadata")
      end
      it "updates the descriptive metadata" do
        expect {
          put :update, id: object, descMetadata: {title: ["Updated"]}, comment: "Just for fun!"
          object.reload
        }.to change { object.dc_title }
      end
      it "creates an update event" do
        expect {
          put :update, id: object, descMetadata: {title: ["Updated"]}, comment: "Just for fun!"
        }.to change { object.update_events.count }.by(1)
      end
      it "records the comment in the update event" do
        put :update, id: object, descMetadata: {title: ["Updated"]}, comment: "Just for fun!"
        expect(object.update_events.last.comment).to eq "Just for fun!"
      end
      it "adds an action-specific summary to the event" do
        put :update, id: object, descMetadata: {title: ["Updated"]}, comment: "Just for fun!"
        expect(object.update_events.last.summary).to eq "Descriptive metadata updated"
      end
    end
    describe "when the user cannot edit" do
      it "is unauthorized" do
        put :update, id: object, descMetadata: {title: ["Updated"]}, comment: "Just for fun!"
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#roles" do
    describe "when the user can grant roles" do
      before do
        object.roles.grant type: "Curator", agent: user
        object.save!
      end
      it "renders the roles template" do
        get :roles, id: object
        expect(response).to render_template(:roles)
      end
    end
    describe "when the user cannot grant roles" do
      it "is unauthorized" do
        get :roles, id: object
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#admin_metadata" do
    describe "GET" do
      describe "when the user can update admin metadata" do
        before do
          object.roles.grant type: "Editor", agent: user
          object.save!
        end
        it "renders the admin_metadata template" do
          get :admin_metadata, id: object
          expect(response).to render_template(:admin_metadata)
        end
      end
      describe "when the user cannot update admin metadata" do
        it "is unauthorized" do
          get :admin_metadata, id: object
          expect(response.response_code).to eq(403)
        end
      end
    end
    describe "PATCH" do
      describe "when the user can update admin metadata" do
        before do
          object.roles.grant type: "Editor", agent: user
          object.save!
        end
        it "redirects to the admin metadata tab of the show page" do
          patch :admin_metadata, id: object, adminMetadata: {local_id: "foobar"}, comment: "This is serious!"
          expect(response).to redirect_to(action: "show", id: object, tab: "admin_metadata")
        end
        it "updates the object" do
          expect {
            patch :admin_metadata, id: object, adminMetadata: {local_id: "foobar"}, comment: "This is serious!"
            object.reload
          }.to change { object.adminMetadata.local_id }
        end
        it "creates an update event" do
          expect {
            patch :admin_metadata, id: object, adminMetadata: {local_id: "foobar"}, comment: "This is serious!"
          }.to change { object.update_events.count }.by(1)
        end
        it "records the comment in the update event" do
          patch :admin_metadata, id: object, adminMetadata: {local_id: "foobar"}, comment: "This is serious!"
          expect(object.update_events.last.comment).to eq "This is serious!"
        end
        it "adds an action-specific summary to the event" do
          patch :admin_metadata, id: object, adminMetadata: {local_id: "foobar"}, comment: "This is serious!"
          expect(object.update_events.last.summary).to eq "Administrative metadata updated"
        end
      end
      describe "when the user cannot update admin metadata" do
        it "is unauthorized" do
          patch :admin_metadata, id: object, adminMetadata: {local_id: "foobar"}, comment: "This is serious!"
          expect(response.response_code).to eq(403)
        end
      end
    end
  end

end
