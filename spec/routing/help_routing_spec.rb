require 'spec_helper'

describe "help routing" do
  describe "help route", type: :request do
    it "should have a help route" do
      get "/help"
      expect(response).to redirect_to("http://library.duke.edu/about/depts/repositoryservices/ddr")
    end
  end
end