module MetadataFilesHelper

  def new_metadata_file_link
    link_to I18n.t('batch.metadata_file.new'), new_metadata_file_path
  end
  
  def metadata_file_profiles
    profiles = {}
    files = Dir.glob(File.join(metadata_file_profiles_dir, "*.yml"))
    files.each do |f|
      profiles[metadata_file_profile_name(f)] = f
    end
    return profiles
  end
  
  def metadata_file_profile_name(file)
    File.basename(file, ".yml").gsub('_', ' ').capitalize
  end
  
  def metadata_file_profiles_dir
    File.join(Rails.root, 'config', 'metadata_file_profiles')
  end
  
end