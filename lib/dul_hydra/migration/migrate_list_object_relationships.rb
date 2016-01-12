module DulHydra::Migration
  class MigrateListObjectRelationships

    attr_reader :pid_list

    def initialize(pid_list_file_path)
      @pid_list = []
      File.open(pid_list_file_path).each_line { |line| pid_list.push line.chomp }
    end

    def migrate
      pid_list.each do |pid|
        Resque.enqueue(DulHydra::Migration::MigrateSingleObjectRelationshipsJob, pid)
      end
    end

  end
end
