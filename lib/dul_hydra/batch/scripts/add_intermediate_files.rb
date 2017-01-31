module DulHydra::Batch::Scripts

  class AddIntermediateFiles

    attr_reader :user, :filepath

    INTERMEDIATE_EXTENSIONS = [ '.jpg', '.jpeg' ]

    def initialize(args)
      @user = User.find_by_user_key(args.fetch(:batch_user))
      raise DulHydra::BatchError, "Unable to find user #{args.fetch(:batch_user)}" unless @user.present?
      @filepath = args.fetch(:filepath)
    end

    def execute
      entries = Dir.entries(filepath).select { |entry| INTERMEDIATE_EXTENSIONS.include?(File.extname(entry).downcase) }
      entries.each do |entry|
        Resque.enqueue(AddIntermediateFileJob, user: user.user_key, filepath: filepath, intermediate_file: entry)
      end
    end

  end

end

