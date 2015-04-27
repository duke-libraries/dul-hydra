require 'spec_helper'

RSpec.describe 'shared/_flash_messages.html.erb', type: :view do

  before do
    FactoryGirl.create(:message, :active, message: "Active")
    FactoryGirl.create(:message, message: "Inactive")
  end

  it "should include the active message(s)" do
    render partial: 'shared/flash_messages'
    expect(rendered).to match(/Active/)
    expect(rendered).to_not match(/Inactive/)
  end

end
