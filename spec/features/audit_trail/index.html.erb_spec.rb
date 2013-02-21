require 'spec_helper'

describe "audit_trail/index.html.erb" do
  subject { page }
  let(:object) { FactoryGirl.create(:test_model) }
  before { visit audit_trail_index_path(object) }
  after { object.delete }
  it "should display the audit trail" do
    expect(subject).to have_content(object.pid)
    expect(subject).to have_link("Download Raw XML", :href => "#{audit_trail_index_path(object)}?download=true")
  end
end
