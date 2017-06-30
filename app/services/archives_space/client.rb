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

    def self.http(&block)
      new.http(&block)
    end

    def self.become(other, &block)
      new.become(other, &block)
    end

    def self.authorized?(user, permissions)
      new.authorized?(user, permissions)
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

    module RequestMethods
      def get(*args, **opts)
        request(:get, *args, **opts)
      end

      def post(*args, **opts)
        request(:post, *args, **opts)
      end

      def delete(*args, **opts)
        request(:delete, *args, **opts)
      end

      def version
        request(:version)
      end

      private

      def request(method, *args, **opts)
        http { |conn| conn.send(method, *args) }
      end
    end

    include RequestMethods
    extend RequestMethods

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

      def get(*args)
        request(:get, *args)
      end

      def post(*args)
        request(:post, *args)
      end

      def delete(*args)
        request(:delete, *args)
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

      def version
        conn.get("/version").body
      end

      private

      def session
        auth["session"]
      end

      def request(method, *args)
        request_args = args.dup << request_headers
        response = conn.send(method, *request_args)
        response.value
        JSON.parse(response.body).tap do |json|
          logger.debug "ASpace response: #{json}"
        end
      rescue Net::HTTPServerException => e
        raise Client::Error, e.message
      end

      def request_headers
        { "X-ArchivesSpace-Session" => session }
      end
    end

  end
end
