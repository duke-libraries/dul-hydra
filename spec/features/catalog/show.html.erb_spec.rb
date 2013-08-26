require 'spec_helper'

describe "catalog/show.html.erb" do
  context "admin policy" do
    let(:apo) { AdminPolicy.create }
    before do
      apo.permissions = [ DulHydra::Permissions::PUBLIC_READ_ACCESS ]
      apo.default_permissions = [ DulHydra::Permissions::REGISTERED_READ_ACCESS ]
      apo.save!
      visit catalog_path(apo)
    end
    after { apo.delete }
    it "should display the default permissions" do
      page.should have_content('registered')
    end
  end

end
