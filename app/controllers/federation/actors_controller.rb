module Federation
  class ActorsController < FederationApplicationController
    before_action :set_federation_actor, only: [:show]

    def show; end

    private
    def set_federation_actor
      puts("もしかしてここ？")
      @actor = Actor.find(params[:id])
      authorize @actor
    end
  end
end
