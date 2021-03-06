module ArchivesSpace
  class Client

    class Error < ::StandardError; end
    class Unauthorized < Error; end
    class AuthenticationError < Error; end

    class_attribute :user, :password, :backend_url
    self.user        = ENV["ASPACE_USER"]
    self.password    = ENV["ASPACE_PASSWORD"]
    self.backend_url = ENV["ASPACE_BACKEND_URL"]

    delegate :logger, to: :Rails

    attr_reader :backend_uri
    attr_accessor :original_auth, :became_auth

    class << self
      delegate :http, :get, :post, :become, :authorized?, to: :new
    end

    def initialize
      @backend_uri = URI(backend_url)
      @original_auth = nil
      @became_auth = nil
      authenticate!
    end

    def auth
      became_auth || original_auth
    end

    def become(other)
      username = other.respond_to?(:aspace_username) ? other.aspace_username : other.to_s
      self.became_auth = post("/users/#{username}/become-user", nil)
      if block_given?
        # yields to block, "unbecomes" user, and returns value of block
        yield(self).tap { unbecome }
      end
    end

    def unbecome
      self.became_auth = nil
    end

    def current_user
      ArchivesSpace::User.new auth["user"]
    end

    def get(*args)
      http { |conn| conn.get(*args) }
    end

    def post(*args)
      http { |conn| conn.post(*args) }
    end

    def authenticated?
      !!original_auth
    end

    def authenticate!
      Net::HTTP.start(backend_uri.host, backend_uri.port, use_ssl: backend_uri.scheme == 'https') do |conn|
        response = conn.post("/users/#{user}/login", URI.encode_www_form(password: password))
        response.value
        self.original_auth = JSON.parse(response.body)
        logger.debug "ASpace login: #{original_auth}"
      end
    rescue Net::HTTPServerException => e
      raise AuthenticationError, e.message
    end

    def http
      Net::HTTP.start(backend_uri.host, backend_uri.port, use_ssl: backend_uri.scheme == 'https') do |conn|
        yield Http.new(conn, auth)
      end
    end

    def authorized?(username, permissions)
      become(username) do
        http { |conn| conn.authorized?(permissions) }
      end
    rescue Error => e
      if e.message =~ /404/ # i.e., user not found
        false
      else
        raise
      end
    end

    class Http
      attr_reader :conn, :auth
      delegate :logger, to: :Rails

      def initialize(conn, auth)
        @conn = conn
        @auth = auth
      end

      def get(path, initheader={})
        headers = initheader.merge(session_header)
        response = conn.get(path, headers)
        handle_response(response)
      end

      def post(path, data=nil, initheader={})
        headers = initheader.merge(session_header)
        response = conn.post(path, data, headers)
        handle_response(response)
      end

      def user
        @user ||= ArchivesSpace::User.new(auth["user"])
      end

      def authorize!(perms)
        unless authorized?(perms)
          raise Client::Unauthorized, "ASpace requires permission(s): #{perms}"
        end
      end

      def authorized?(perms)
        Array(perms).all? { |p| user.permissions.include?(p) }
      end

      def find_resource_by_ead_id(ead_id)
        query = {"query"=>{"field"=>"ead_id", "value"=>ead_id, "jsonmodel_type"=>"field_query", "negated"=>false, "literal"=>false}}
        params = URI.encode_www_form("page"=>"1", "aq"=>query.to_json)
        results = get("/repositories/2/search?#{params}")
        if results["total_hits"] == 0
          raise Client::Error, "No resource found for EAD ID: #{ead_id}"
        end
        result = results["results"].first
        resource = get(result["id"])
      end

      def find_ao(ref_id, ead_id = nil)
        params = URI.encode_www_form("ref_id[]"=>ref_id)
        results = get("/repositories/2/find_by_id/archival_objects?#{params}")["archival_objects"]
        case results.length
        when 0
          raise Client::Error, "Archival object not found for ref id #{ref_id}."
        when 1
          get(results.first["ref"])
        else
          if !ead_id
            raise Client::Error,
                  "Multiple archival objects found for ref id #{ref_id} and EAD ID not provided."
          end
          resource = find_resource_by_ead_id(ead_id)
          results.each do |result|
            ao = get(result["ref"])
            return ao if ao["resource"]["ref"] == resource["uri"]
          end
          raise Client::Error,
                "Multiple archival objects found for ref id #{ref_id} and none match EAD ID #{ead_id}."
        end
      end

      private

      def session
        auth["session"]
      end

      def handle_response(response)
        response.value
        JSON.parse(response.body).tap do |json|
          logger.debug "ASpace response: #{json}"
        end
      rescue Net::HTTPServerException => e
        raise Client::Error, e.message
      end

      def session_header
        { "X-ArchivesSpace-Session" => session }
      end
    end

  end
end
