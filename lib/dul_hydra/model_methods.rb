module DulHydra

  module ModelMethods

    def find_by_identifier(identifier)
      results = []
      find_each("identifier_s:#{identifier}*") do
        |x| results << x
      end
      results
    end

  end

end
