module DulHydra::Scripts
  class ProcessMETSFolder < CreatePendingBatchScript

    attr_reader :mets_folder

    DEFAULT_CONFIG_FILE = Rails.root.join('config', 'mets_folder.yml')

    def initialize(params)
      @mets_folder = METSFolder.create(params)
    end

    def execute
      collection = Collection.find(mets_folder.collection_id)
      inspection_results = InspectMETSFolder.new(mets_folder).call
      user_choice = user_interaction(collection, inspection_results)
      batch_info = {
          batch_user: mets_folder.user,
          inspection_results: inspection_results,
          collection: collection,
          batch_description: inspection_results.filesystem.root.name
      }
      respond_to_user_choice(user_choice, batch_info)
    end

    def user_interaction(collection, inspection_results)
      puts "Collection   : #{collection.dc_title.first}"
      puts "Base Path    : #{mets_folder.base_path}"
      puts "Folder Path  : #{mets_folder.sub_path}"
      puts "Files Scanned: #{inspection_results.file_count}"
      puts "Excluding ..."
      inspection_results.exclusions.each { |exc| puts "  - #{exc}" }
      puts "Warnings ..."
      inspection_results.warnings.each { |w| puts "  - #{w}" }
      puts "Errors ..."
      inspection_results.errors.each { |e| puts "  - #{e}" }
      prompt_user
    end

    def build_batch(batch_user:, inspection_results:, collection:, batch_name: 'METS Folder Update',
                    batch_description: nil, display_formats: METSFolderConfiguration.new.display_format_config)
      BuildBatchFromMETSFolder.new(
          batch_user: batch_user,
          filesystem: inspection_results.filesystem,
          collection: collection,
          batch_name: batch_name,
          batch_description: batch_description,
          display_formats: display_formats
      ).call
    end

  end
end
