module DulHydra
  module Batch
    module Scripts

      class CreatePendingBatchScript

        def load_configuration(config_file)
          YAML::load(File.read(config_file)).symbolize_keys
        end

        def user_options
          options = {}
          options['p'] = "Create pending batch"
          options['x'] = "Cancel operation"
          options
        end

        def prompt_user
          user_options.each { |k, v| puts "#{k} - #{v}" }
          get_user_choice
        end

        def get_user_choice
          input = ""
          while true do
            print "Enter #{user_options.keys.join(', ')} : "
            input = STDIN.gets.strip
            break if user_options.keys.include?(input.downcase)
          end
          input.downcase
        end

        def respond_to_user_choice(choice, batch_args={})
          case choice
          when 'p'
            batch = build_batch(batch_args)
            puts "Created pending batch #{batch.id} for user #{batch.user.user_key}"
          when 'x'
            puts "Cancelling operation"
          end
        end

      end

    end
  end
end