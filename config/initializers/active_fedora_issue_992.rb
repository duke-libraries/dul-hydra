#
# Monkey patches https://github.com/projecthydra/active_fedora/issues/992
#
require 'active_fedora/file/streaming'

module ActiveFedora::File::Streaming
  class FileBody
    def each
      ssl = uri.scheme == 'https' ? true : false
      Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
        request = Net::HTTP::Get.new uri, headers
        http.request request do |response|
          raise "Couldn't get data from Fedora (#{uri}). Response: #{response.code}" unless response.is_a?(Net::HTTPSuccess)
          response.read_body do |chunk|
            yield chunk
          end
        end
      end
    end
  end
end
