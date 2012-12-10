require 'spec_helper'

shared_examples "a DulHydra controller" do 
  def object_class
    Object.const_get(object_class_name)
  end
  def object_class_name
    described_class.sub("Controller", "").singularize
  end
  def resource
    instance_variable_get("@#{object_class_name.downcase}")
  end
  shared_examples "object creator" do
    context "authenticated user" do
      it "creates a new object" do
        resource.should be_kind_of(object_class)
      end
    end
    context "anonymous user" do
      it "should deny access" do
        response.code.should eq(403)
      end
    end
  end
  context "#index" do
    it "requires discover access to the objects"
    it "retrieves the existing objects"
  end
  context "#new" do
    include_examples "object creator"
  end
  context "#create" do
    include_examples "object creator"
    it "saves the object to the repository"
    it "redirects to the show page for the object"
  end
  context "#show" do
    it "requires read access to the object"
    it "retrieves the object"
  end
  context "#edit" do
    it "requires edit access to the object"
    it "retrieves the object"
  end
  context "#update" do
    it "requires edit access to the object"
    it "retrieves the object"
    it "updates the attributes of the object"
    it "saves the object"
    it "redirects to the show page for the object"
  end
  context "#destroy" do
    it "requires edit access to the object"
    it "retrieves the object"
    it "deletes the object"
    it "redirects to the index page"
  end
end
