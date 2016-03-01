module DulHydra
  module Controller
    module PublicationBehavior

      def publish
        current_object.publish!
        flash[:success] = "Collection (and descendants) published"
        render "show"
      end

      def unpublish
        current_object.unpublish!
        flash[:success] = "Collection (and descendants) un-published"
        render "show"
      end

    end
  end
end
