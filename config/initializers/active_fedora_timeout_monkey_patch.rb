class ActiveFedora::Fedora
  def authorized_connection
    options = {}
    if @config[:timeout]
      options[:request] = { timeout: @config[:timeout].to_i }
    end
    connection = Faraday.new(host, options)
    connection.basic_auth(user, password)
    connection
  end
end
