require 'spec_helper'

module Mailers

  RSpec.describe JobMailer, type: :mailer do
    it "should generate an email" do
      JobMailer.basic(subject: 'Job', to: 'user@example.com', message: 'Job completed').deliver!
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end
  end
end
