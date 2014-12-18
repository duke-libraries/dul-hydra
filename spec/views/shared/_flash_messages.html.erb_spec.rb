require 'spec_helper'

RSpec.describe 'shared/_flash_messages.html.erb', type: :view do

  before do
    FactoryGirl.create(:message, :active, :ddr, message: "Active Ddr")
    FactoryGirl.create(:message, :ddr, message: "Inactive Ddr")
    FactoryGirl.create(:message, :active, :repository, message: "Active Repository")
  end

  it "should include the active ddr message(s)" do
    render partial: 'shared/flash_messages'
    expect(rendered).to match(/Active Ddr/)
    expect(rendered).to_not match(/Inactive Ddr/)
    expect(rendered).to_not match(/Active Repository/)
  end

end