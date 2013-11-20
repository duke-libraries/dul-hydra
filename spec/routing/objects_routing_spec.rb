require 'spec_helper'

describe "object routes" do

  describe "RESTful routes" do
    it "should not have an index route" do
      expect(:get => '/objects').not_to be_routable
    end
    it "should have a show route" do
      @route = {controller: 'objects', action: 'show', id: 'duke:1'}
      expect(:get => '/objects/duke:1').to route_to(@route)
      expect(:get => object_path('duke:1')).to route_to(@route)
    end
    it "should have a new route" do
      @route = {controller: 'objects', action: 'new'}
      expect(:get => '/objects/new').to route_to(@route)
      expect(:get => new_object_path).to route_to(@route)
    end
    it "should not have a create route" do
      expect(:post => '/objects').not_to be_routable
    end    
    it "should not have an edit route" do
      expect(:get => '/objects/duke:1/edit').not_to be_routable
    end
    it "should not have an update route" do
      expect(:put => '/objects/duke:1').not_to be_routable
    end
    it "should not have a destroy route" do
      expect(:delete => '/objects/duke:1').not_to be_routable
    end
  end

  describe "non-RESTful routes" do
    it "should have a 'collection_info' route" do
      @route = {controller: 'objects', action: 'collection_info', id: 'duke:1'}
      expect(:get => '/objects/duke:1/collection_info').to route_to(@route)
      expect(:get => collection_info_object_path('duke:1')).to route_to(@route)
    end
    it "should have a 'download' route" do
      @route = {controller: 'downloads', action: 'show', id: 'duke:1'}
      expect(:get => '/objects/duke:1/download').to route_to(@route)
      expect(:get => download_object_path('duke:1')).to route_to(@route)
    end
    it "should have a 'preservation_events' route" do
      @route = {controller: 'objects', action: 'preservation_events', id: 'duke:1'}
      expect(:get => '/objects/duke:1/preservation_events').to route_to(@route)
      expect(:get => preservation_events_object_path('duke:1')).to route_to(@route)
    end
    it "should have a 'thumbnail' route" do
      @route = {controller: 'thumbnail', action: 'show', id: 'duke:1'}
      expect(:get => '/objects/duke:1/thumbnail').to route_to(@route)
      expect(:get => thumbnail_object_path('duke:1')).to route_to(@route)
    end
    it "should have a datastream download route" do
      @route = {controller: 'downloads', action: 'show', id: 'duke:1', datastream_id: 'content'}
      expect(:get => '/objects/duke:1/datastreams/content').to route_to(@route)
      expect(:get => download_datastream_object_path('duke:1', 'content')).to route_to(@route)
    end

    describe "descriptive metadata routes" do
      it "should have a show route" do
        @route = {controller: 'objects', action: 'show', id: 'duke:1', tab: 'descriptive_metadata'}
        expect(:get => '/objects/duke:1/descriptive_metadata').to route_to(@route)
        expect(:get => record_path('duke:1')).to route_to(@route)
      end
      it "should have an edit route" do
        @route = {controller: 'objects', action: 'edit', id: 'duke:1'}
        expect(:get => '/objects/duke:1/descriptive_metadata/edit').to route_to(@route)
        expect(:get => record_edit_path('duke:1')).to route_to(@route)
      end    
      it "should have an update route" do
        @route = {controller: 'objects', action: 'update', id: 'duke:1'}
        expect(:put => '/objects/duke:1/descriptive_metadata').to route_to(@route)
        expect(:put => record_path('duke:1')).to route_to(@route)
      end    
    end

    describe "permissions routes" do
      it "should have a show route" do
        @route = {controller: 'objects', action: 'show', id: 'duke:1', tab: 'permissions'}
        expect(:get => '/objects/duke:1/permissions').to route_to(@route)
        expect(:get => permissions_path('duke:1')).to route_to(@route)
      end
      it "should have an edit route" do
        @route = {controller: 'permissions', action: 'edit', id: 'duke:1'}
        expect(:get => '/objects/duke:1/permissions/edit').to route_to(@route)
        expect(:get => permissions_edit_path('duke:1')).to route_to(@route)
      end
      it "should have an update route" do
        @route = {controller: 'permissions', action: 'update', id: 'duke:1'}
        expect(:put => '/objects/duke:1/permissions').to route_to(@route)
        expect(:put => permissions_path('duke:1')).to route_to(@route)
      end
    end

    describe "default permissions routes" do
      it "should have a show route" do
        @route = {controller: 'objects', action: 'show', id: 'duke:1', tab: 'default_permissions'}
        expect(:get => '/objects/duke:1/default_permissions').to route_to(@route)
        expect(:get => default_permissions_path('duke:1')).to route_to(@route)
      end
      it "should have an edit route" do
        @route = {controller: 'permissions', action: 'edit', default_permissions: true, id: 'duke:1'}
        expect(:get => '/objects/duke:1/default_permissions/edit').to route_to(@route)
        expect(:get => default_permissions_edit_path('duke:1')).to route_to(@route)
      end
      it "should have an update route" do
        @route = {controller: 'permissions', action: 'update', default_permissions: true, id: 'duke:1'}
        expect(:put => '/objects/duke:1/default_permissions').to route_to(@route)
        expect(:put => default_permissions_path('duke:1')).to route_to(@route)
      end
    end

    describe "other object show tabs" do
      it "should have an attachments route" do
        @route = {controller: 'objects', action: 'show', id: 'duke:1', tab: 'attachments'}
        expect(:get => '/objects/duke:1/attachments').to route_to(@route)
        expect(:get => object_tab_path('duke:1', 'attachments')).to route_to(@route)        
      end
      it "should have an items route" do
        @route = {controller: 'objects', action: 'show', id: 'duke:1', tab: 'items'}
        expect(:get => '/objects/duke:1/items').to route_to(@route)
        expect(:get => object_tab_path('duke:1', 'items')).to route_to(@route)        
      end
      it "should have a components route" do
        @route = {controller: 'objects', action: 'show', id: 'duke:1', tab: 'components'}
        expect(:get => '/objects/duke:1/components').to route_to(@route)
        expect(:get => object_tab_path('duke:1', 'components')).to route_to(@route)        
      end
    end

  end
end
