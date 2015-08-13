require_relative 'simple_job'

module DulHydra::Jobs
  class SimpleJobFactory

    def self.call(queue, &proc)
      Class.new(SimpleJob) do
        self.queue = queue
        self.proc = proc
      end
    end

  end
end
