require 'spec_helper'

describe Collection do

  before do
    @collection_pid = "collection:1"
    @collection = Collection.create(:pid => @collection_pid)
  end

  after do
    @collection.delete
  end

end
