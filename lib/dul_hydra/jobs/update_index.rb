module DulHydra::Jobs
  class UpdateIndex

    @queue = :index

    def self.perform(pid)
      obj = ActiveFedora::Base.find(pid)
      obj.update_index
    end

  end
end
