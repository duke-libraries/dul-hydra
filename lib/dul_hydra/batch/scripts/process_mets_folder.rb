module DulHydra
  module Batch
    module Scripts

      class ProcessMETSFolder < CreatePendingBatchScript

        include ActionView::Helpers::TextHelper

        attr_reader :batch_user, :collection, :configuration, :folder

        DEFAULT_CONFIG_FILE = Rails.root.join('config', 'mets_folder.yml')

        def initialize(batch_user:, folder:, collection_pid:, config_file: DEFAULT_CONFIG_FILE)
          puts "Using config file #{config_file}"
          @batch_user = User.find_by_user_key(batch_user)
          raise DulHydra::BatchError, "Unable to find user #{batch_user}" unless @batch_user.present?
          @collection = Collection.find(collection_pid)
          @configuration = load_configuration(config_file)
          @folder = folder
        end

        def execute
          inspection_results = inspect_folder
          user_choice = prompt_user
          respond_to_user_choice(user_choice, { filesystem: inspection_results.filesystem })
        end

        private

        def inspect_folder
          results = InspectMETSFolder.new(folder, collection, configuration[:scanner]).call
          puts "Inspected #{results.filesystem.root.name}"
          puts "Found #{results.file_count} files"
          unless results.exclusions.empty?
            puts "Excluding #{results.exclusions.join(', ')}"
          end
          results.warnings.each { |warn| puts "WARNING: #{warn}" }
          results.errors.each { |err| puts "ERROR: #{err}" }
          puts "Inspection generated #{pluralize(results.warnings.size, 'WARNING', 'WARNINGS')} and #{pluralize(results.errors.size, 'ERROR', 'ERRORS')}"
          results
        end

        def build_batch(batch_args)
          filesystem = batch_args[:filesystem]
          batch_builder = BuildBatchFromMETSFolder.new(
                              batch_user: batch_user,
                              filesystem: filesystem,
                              collection: collection,
                              batch_description: filesystem.root.name,
                              display_formats: configuration[:display_format])
          batch = batch_builder.call
        end

      end

    end
  end
end
