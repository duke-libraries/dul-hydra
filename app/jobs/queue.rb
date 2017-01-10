require "resque"

class Queue

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def size
    Resque.size(name)
  end

  # @return [Array<Hash>] jobs in the queue, optionally filtered by type,
  #   start position, and count.
  def jobs(type: nil, start: 0, count: nil)
    jobs = Resque.peek(name, start, count || size)
    if type
      jobs.select! { |job| job["class"] == type.to_s }
    end
    jobs
  end

end
