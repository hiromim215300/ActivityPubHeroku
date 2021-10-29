require 'fediverse/inbox'

module Federation
  class ActivitiesController < FederationApplicationController
    before_action :set_federation_activity, only: [:show]

    def outbox
      @actor            = Actor.find(params[:actor_id])
      @activities       = policy_scope Activity.where(actor: @actor).order(created_at: :desc)
      @total_activities = @activities.count
      @activities       = @activities.page(params[:page])
    end

    def show; end

    def create
      payload = payload_from_params
      return render json: {}, status: :unprocessable_entity unless payload

      if Fediverse::Inbox.dispatch_request(payload)
        render json: {}, status: :created
      else
        render json: {}, status: :unprocessable_entity
      end
    end

    private

    def set_federation_activity
      @activity = Activity.find_by!(actor_id: params[:actor_id], id: params[:id])
    end

    def activity_params
      params.fetch(:activity, {})
    end

    def payload_from_params
      payload_string = request.body.read
      request.body.rewind if request.body.respond_to? :rewind

      begin
        payload = JSON.parse(payload_string)
      rescue JSON::ParserError
        return
      end

      hash = JSON::LD::API.compact payload, payload['@context']
      validate_payload hash
    end

    def validate_payload(hash)
      return unless hash['@context'] && hash['id'] && hash['type'] && hash['actor'] && hash['object'] && hash['to']

      hash
    end
  end
end

