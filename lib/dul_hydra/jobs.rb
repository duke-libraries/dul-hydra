require_relative 'jobs/simple_job_factory'

module DulHydra
  module Jobs

    FixityCheck = SimpleJobFactory.call(:fixity) { |obj| obj.fixity_check }

    UpdateIndex = SimpleJobFactory.call(:index) { |obj| obj.update_index }

  end
end
