class User < ActiveRecord::Base
  include Hydra::User
  include Blacklight::User
  include DulHydra::Models::User
  include DulHydra::Grouper::User
end
