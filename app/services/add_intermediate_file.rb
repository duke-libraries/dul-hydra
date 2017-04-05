class AddIntermediateFile

  attr_reader :user, :filepath, :intermediate_file, :checksum

  def initialize(args)
    @user = args.with_indifferent_access.fetch(:user)
    @filepath = args.with_indifferent_access.fetch(:filepath)
    @intermediate_file = args.with_indifferent_access.fetch(:intermediate_file)
    @checksum = args.with_indifferent_access.fetch(:checksum, nil)
  end

  def process
    base_name = File.basename(intermediate_file, '.*')
    component = find_matching_component(base_name)
    component.add_file(File.join(filepath, intermediate_file), Ddr::Datastreams::INTERMEDIATE_FILE)
    component.save!(user: user)
    if checksum.present?
      component.reload
      component.datastreams[Ddr::Datastreams::INTERMEDIATE_FILE].validate_checksum!(checksum)
    end
  end

  def find_matching_component(local_id)
    matches = Component.where(Ddr::Index::Fields::LOCAL_ID => local_id)
    case
      when matches.size == 0
        raise DulHydra::Error, "Unable to find Component matching local_id '#{local_id}' for #{intermediate_file}"
      when matches.size > 1
        raise DulHydra::Error, "Multiple Components matching local_id '#{local_id}' for #{intermediate_file}"
    end
    matches.first
  end
end
