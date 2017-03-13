require 'hashie'

module ArchivesSpace
  class User < Hashie::Mash

    def permissions
      self["permissions"]["/repositories/2"]
    end

  end
end
