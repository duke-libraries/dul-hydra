require 'noid'

module DulHydra
  module Services
    module IdService

      def self.noid_template
        DulHydra.noid_template
      end

      @minter = ::Noid::Minter.new(template: noid_template)
      @semaphore = Mutex.new
      
      def self.valid? noid
        @minter.valid? noid
      end

      def self.mint
        @semaphore.synchronize do
          while true
            noid = self.next_id
            return noid unless ActiveFedora::Base.exists?(DulHydra::IndexFields::PERMANENT_ID => noid)
          end
        end
      end

      protected

      def self.next_id
        noid = ''
        File.open(DulHydra.minter_statefile, File::RDWR|File::CREAT, 0644) do |f|
          f.flock(File::LOCK_EX)
          yaml = YAML::load(f.read)
          yaml = {template: noid_template} unless yaml
          minter = ::Noid::Minter.new(yaml)
          noid = minter.mint
          f.rewind
          yaml = YAML::dump(minter.dump)
          f.write yaml
          f.flush
          f.truncate(f.pos)
        end
        noid
      end

    end
  end
end