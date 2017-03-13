RSpec.describe User do

  describe "Duke user" do
    subject { described_class.new(username: "foo@duke.edu") }
    its(:aspace_username) { is_expected.to eq "foo" }
  end

  describe "other user" do
    subject { described_class.new(username: "foo") }
    its(:aspace_username) { is_expected.to be_nil }
  end

end
