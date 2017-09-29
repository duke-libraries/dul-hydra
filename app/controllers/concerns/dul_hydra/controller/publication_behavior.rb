module DulHydra
  module Controller
    module PublicationBehavior

      def publish
        Resque.enqueue(PublishJob, current_object.id, current_user.email)
        flash[:success] = "#{publication_scope} queued to be published"
        redirect_to action: :show
      end

      def unpublish
        Resque.enqueue(UnPublishJob, current_object.id, current_user.email)
        flash[:success] = "#{publication_scope} queued to be un-published"
        redirect_to action: :show
      end

      def publication_scope
        I18n.t("dul_hydra.publication.scope.#{current_object.class.to_s.downcase}")
      end
    end
  end
end
