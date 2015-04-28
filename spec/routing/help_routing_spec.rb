require 'spec_helper'

describe "help routing", :type => :routing do
  describe "help route", type: :request do
    it "should have a help route" do
      get "/help"
      expect(response).to redirect_to(DulHydra.help_url)
    end
  end
end
