require 'csv'

module ArchivesSpace
  #
  # This service is intended to function as a non-interactive version of
  # https://github.com/duke-libraries/archivesspace-duke-scripts/blob/master/python/duke_update_archival_object.py
  #
  class CreateDigitalObjects

    FAILURE = "FAILURE"
    SUCCESS = "SUCCESS"

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

    CSV_IN_HEADERS = %w( aspace_id permanent_id permanent_url title display_format )

    CSV_OUT_HEADERS = [
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
    ]

    delegate :logger, to: :Rails

    def self.authorized?(user)
      Client.authorized?(user, PERMISSIONS)
    end

    def self.call(*args)
      new(*args).call
    end

    attr_reader :csv_in, :publish, :user

    def initialize(csv, user: nil, publish: false)
      csv_in = csv.respond_to?(:read) ? csv.read : csv
      @csv_in = CSV.parse(csv_in.to_s, CSV_IN_OPTS)
      unless CSV_IN_HEADERS.all? { |h| @csv_in.headers.include?(h) }
        raise "Input CSV missing one or more required headers: #{CSV_IN_HEADERS}"
      end
      @user = user
      @publish = publish
    end

    def use_statement_for(value)
      USE_STATEMENT_MAPPING[value]
    end

    def call
      client = Client.new
      client.become(user) if user
      client.http do |conn|
        conn.authorize!(PERMISSIONS)

        CSV.generate(CSV_OUT_OPTS) do |csv_out|
          csv_out << CSV_OUT_HEADERS

          csv_in.each do |row|
            outcome, published, archival_object_uri, digital_object_uri,
            digital_object_id, file_uri, digital_object_title, use_statement = nil

            ref_id = row["aspace_id"]

            # Find AO
            params = URI.encode_www_form("ref_id[]"=>ref_id)
            results = conn.get("/repositories/2/find_by_id/archival_objects?#{params}")["archival_objects"]

            if results.blank?
              logger.error "Archival object not found for id: #{ref_id}"
              outcome = FAILURE
            else
              archival_object_uri = results.first["ref"]
              archival_object = conn.get(archival_object_uri)

              digital_object_id    = row["permanent_id"]
              digital_object_title = row["title"] || archival_object["display_string"]
              file_uri             = row["permanent_url"]
              use_statement        = use_statement_for(row["display_format"])

              # Create DO
              data = {
                title: digital_object_title,
                digital_object_id: digital_object_id,
                file_versions: [
                  { file_uri: file_uri,
                    use_statement: use_statement,
                  }
                ],
              }

              digital_object_uri = conn.post("/repositories/2/digital_objects", data.to_json)["uri"]
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

              conn.post(archival_object_uri, archival_object.to_json)
              logger.info "ASpace digital object #{digital_object_uri} " \
                          "linked to archival object #{archival_object_uri}."

              outcome = SUCCESS

            end # if archival_object

            csv_out << {
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

  end
end
