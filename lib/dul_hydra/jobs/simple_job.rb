module DulHydra::Jobs
  class SimpleJob

    class << self
      attr_accessor :queue, :proc

      def perform(pid)
        obj = ActiveFedora::Base.find(pid)
        proc.call(obj)
      end
    end

  end
end
