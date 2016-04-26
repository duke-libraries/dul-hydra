module DulHydra
  module Controller
    module PublicationBehavior

      def publish
        Resque.enqueue(PublishJob, current_object.id, current_user.email)
        flash[:success] = "Collection (and descendants) queued to be published"
        redirect_to action: :show
      end

      def unpublish
        Resque.enqueue(UnPublishJob, current_object.id, current_user.email)
        flash[:success] = "Collection (and descendants) queued to be un-published"
        redirect_to action: :show
      end

    end
  end
end
