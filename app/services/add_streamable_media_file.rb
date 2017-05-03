class AddStreamableMediaFile

  attr_reader :user, :filepath, :streamable_media_file, :checksum

  def initialize(args)
    @user = args.with_indifferent_access.fetch(:user)
    @filepath = args.with_indifferent_access.fetch(:filepath)
    @streamable_media_file = args.with_indifferent_access.fetch(:streamable_media_file)
    @checksum = args.with_indifferent_access.fetch(:checksum, nil)
  end

  def process
    base_name = File.basename(streamable_media_file, '.*')
    component = find_matching_component(base_name)
    component.add_file(File.join(filepath, streamable_media_file), Ddr::Datastreams::STREAMABLE_MEDIA)
    component.save!(user: user)
    if checksum.present?
      component.reload
      component.datastreams[Ddr::Datastreams::STREAMABLE_MEDIA].validate_checksum!(checksum)
    end
  end

  def find_matching_component(local_id)
    matches = Component.where(Ddr::Index::Fields::LOCAL_ID => local_id)
    case
      when matches.size == 0
        raise DulHydra::Error, "Unable to find Component matching local_id '#{local_id}' for #{streamable_media_file}"
      when matches.size > 1
        raise DulHydra::Error, "Multiple Components matching local_id '#{local_id}' for #{streamable_media_file}"
    end
    matches.first
  end
end
