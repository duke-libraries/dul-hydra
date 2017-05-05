module DulHydra::Batch::Scripts

  class AddStreamableMediaFiles

    attr_reader :user, :filepath, :checksums

    STREAMABLE_MEDIA_EXTENSIONS = [ '.mp3', '.mp4' ]

    def initialize(args)
      @user = User.find_by_user_key(args.fetch(:batch_user))
      raise DulHydra::BatchError, "Unable to find user #{args.fetch(:batch_user)}" unless @user.present?
      @filepath = args.fetch(:filepath)
      checksum_file = args.fetch(:checksum_file, nil)
      @checksums = load_checksums(checksum_file) if checksum_file
    end

    def execute
      entries = Dir.entries(filepath).select { |entry| STREAMABLE_MEDIA_EXTENSIONS.include?(File.extname(entry).downcase) }
       entries.each do |entry|
        AddStreamableMediaFileJob.perform_later(
                       user: user.user_key,
                       filepath: filepath,
                       streamable_media_file: entry,
                       checksum: checksums ? file_checksum(File.join(filepath, entry)) : nil
                      )
      end
    end

    private

    def file_checksum(file_entry)
      @checksums.fetch(file_entry, nil)
    end

    def load_checksums(checksum_file)
      checksum_hash = {}
      begin
        File.open(checksum_file, 'r') do |file|
          file.each_line do |line|
            checksum, path = line.split
            checksum_hash[path] = checksum
          end
        end
      end
      checksum_hash
    end

  end

end

