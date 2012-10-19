require 'spec_helper'

describe Item do

  before do
    @pid = "item:1"
    @item = Item.create(:pid => @pid)
  end

  after do
    @item.delete
  end

end
