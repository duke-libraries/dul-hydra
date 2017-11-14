require 'csv'

module ArchivesSpace
  #
  # This service is intended to function as a non-interactive version of
  # https://github.com/duke-libraries/archivesspace-duke-scripts/blob/master/python/duke_update_archival_object.py
  #
  class CreateDigitalObjects

    FAILURE = "FAILURE"
    SUCCESS = "SUCCESS"
    SKIPPED = "NO ACTION"

    SKIP_REMAINING_ON_ERRORS = [ Errno::ECONNREFUSED ]

    PERMISSIONS = %w( update_resource_record update_digital_object_record )

    CSV_IN_OPTS = {
      headers: true,
      return_headers: false,
    }

    CSV_OUT_OPTS = {
      headers: true,
      write_headers: true,
    }

    USE_STATEMENT_MAPPING = {
      "image"       => "image-service",
      "multi_image" => "image-service",
      "folder"      => "image-service",
      "audio"       => "audio-streaming",
      "video"       => "video-streaming",
      "document"    => "text-service",
    }

    CSV_IN_HEADERS = %w( pid aspace_id ead_id permanent_id permanent_url title display_format )

    CSV_OUT_HEADERS = [
      :repo_id,
      :ref_id,
      :digital_object_id,
      :digital_object_title,
      :file_uri,
      :use_statement,
      :archival_object_uri,
      :digital_object_uri,
      :outcome,
      :published,
      :user,
      :message,
    ]

    delegate :logger, to: :Rails

    def self.authorized?(user)
      Client.authorized?(user, PERMISSIONS)
    end

    def self.call(*args)
      new(*args).call
    end

    attr_reader :csv_in, :publish, :user, :debug

    def initialize(csv, user: nil, publish: false, debug: false)
      csv_in = csv.respond_to?(:read) ? csv.read : csv
      @csv_in = CSV.parse(csv_in.to_s, CSV_IN_OPTS)
      unless CSV_IN_HEADERS.all? { |h| @csv_in.headers.include?(h) }
        raise "Input CSV missing one or more required headers: #{CSV_IN_HEADERS}"
      end
      @user = user
      @publish = publish
      @debug = debug
    end

    def use_statement_for(value)
      USE_STATEMENT_MAPPING[value]
    end

    def call
      client = Client.new
      client.become(user) if user
      client.http do |conn|
        conn.authorize!(PERMISSIONS)

        skip_remaining = false

        CSV.generate(CSV_OUT_OPTS) do |csv_out|
          csv_out << CSV_OUT_HEADERS

          csv_in.each do |row|
            outcome, published, archival_object_uri, digital_object_uri,
            digital_object_id, file_uri, digital_object_title, use_statement, message = nil

            repo_id, ref_id, ead_id = row.values_at("pid", "aspace_id", "ead_id")

            if skip_remaining
              outcome = SKIPPED

            elsif !ref_id
              message = "No ASpace ref id for repository object #{repo_id} - skipping digital object creation."
              logger.debug
              outcome = SKIPPED

            else
              begin
                archival_object      = conn.find_ao(ref_id, ead_id)
                archival_object_uri  = archival_object["uri"]
                digital_object_id    = row["permanent_id"]
                digital_object_title = row["title"] || archival_object["display_string"]
                file_uri             = row["permanent_url"]
                use_statement        = use_statement_for(row["display_format"])

                unless debug
                  data = {
                    title: digital_object_title,
                    digital_object_id: digital_object_id,
                    file_versions: [
                      { file_uri: file_uri,
                        use_statement: use_statement,
                      }
                    ],
                  }

                  digital_object_uri = conn.post("/repositories/2/digital_objects", data.to_json, json_header)["uri"]
                  logger.info "ASPace digital object created: #{digital_object_uri}."

                  # Publish DO, if required
                  if publish
                    conn.post("#{digital_object_uri}/publish", nil)
                    logger.info "ASpace digital object #{digital_object_uri} published."
                    published = true
                  else
                    published = false
                  end

                  # Link DO to AO
                  digital_object_instance = {
                    instance_type: "digital_object",
                    digital_object: { ref: digital_object_uri },
                  }
                  archival_object["instances"] << digital_object_instance

                  conn.post(archival_object_uri, archival_object.to_json, json_header)
                  logger.info "ASpace digital object #{digital_object_uri} " \
                              "linked to archival object #{archival_object_uri}."
                end # unless debug

                outcome = SUCCESS

              rescue Client::Error => e
                message = e.message
                logger.error(message)
                outcome = FAILURE

              rescue *SKIP_REMAINING_ON_ERRORS => e
                message = "Skipping remaining records due to error: #{e.message}"
                logger.error(message)
                outcome = SKIPPED
                skip_remaining = true

              end # begin
            end # if

            csv_out << {
              repo_id: repo_id,
              ref_id: ref_id,
              digital_object_id: digital_object_id,
              digital_object_title: digital_object_title,
              file_uri: file_uri,
              use_statement: use_statement,
              archival_object_uri: archival_object_uri,
              digital_object_uri: digital_object_uri,
              outcome: outcome,
              published: published,
              user: conn.user.username,
            }

          end # csv_in.each
        end # client.http
      end # CSV.generate
    end

    def json_header
      { "Content-Type"=>"application/json" }
    end

  end
end
