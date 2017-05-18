class ComponentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasStructuralMetadataBehavior

  def stream
    if current_object.streamable?

      # Get local development environment to support byte ranges
      # WEBrick does not; otherwise jumping to the middle of an
      # AV file doesn't work.
      # Solution from: http://stackoverflow.com/a/7604330

      if Rails.env.development?

          file_size = File.size(current_object.streamable_media_path)
          file_begin = 0
          file_end = file_size - 1

          if request.headers['Range']
            status_code = :partial_content

            match = request.headers['range'].match(/bytes=(\d+)-(\d*)/)

            if match
              file_begin = match[1]
              file_end = match[1]  if match[2] and not match[2].empty?
            end

            response.headers['Content-Range'] = "bytes #{file_begin}-#{file_end.to_i + (match[2] == '1' ? 1 : 0)}/#{file_size}"
          else
            status_code = :ok
          end

          response.headers['Content-Length'] = file_size.to_s
          response.headers['Cache-Control'] = 'public, must-revalidate, max-age=0'
          response.headers['Pragma'] = 'no-cache'
          response.headers['Accept-Ranges'] = 'bytes'
          response.headers['Content-Transfer-Encoding'] = 'binary'
      
      end

      send_file current_object.streamable_media_path,
                type: current_object.streamable_media_type,
                stream: true,
                disposition: 'inline'
    else
      render nothing: true, status: 404
    end
  end

end
