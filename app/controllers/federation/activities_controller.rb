require 'fediverse/inbox'
require 'uri'
require 'json'
require 'open-uri'
$time=[]
module Federation
#  $time = [] 
  class ActivitiesController < FederationApplicationController
    before_action :set_federation_activity, only: [:show]

    def outbox
      @actor            = Actor.find(params[:actor_id])
      @activities       = policy_scope Activity.where(actor: @actor).order(created_at: :desc)
      @total_activities = @activities.count
      @activities       = @activities.page(params[:page])
    end

    def show; end
#    $time =[]
    def create
      start_time = Time.now
      puts("Create Test start_time=#{start_time}")
      split_request
      for var in split_request do
        start_for_time = Time.now
        payload = payload_from_params(var)
        puts("payload = #{payload}")
        render json: {}, status: :unprocessable_entity unless payload

        if Fediverse::Inbox.dispatch_request(payload)
          puts("テスト1")
       	#dispatch_request(payload)
          render json: {}, status: :created
          puts(":created")
          puts("処理速度=#{Time.now - start_time}s")
        else
#          redirect_to(json: {}, status: :unprocessable_entity)
          puts(":unprocessable_entity")
        end
     # puts("あれ？こここない？") 
#        render json: {}, status: :unprocessable_entity
        end_time = Time.now
        final_time = end_time - start_for_time
        $time.push(final_time)
#        puts($time)
      end
      render json: {}, status: :unprocessable_entity
      final_end_time = Time.now - start_time
     # puts("time = #{$time}")
      puts("final_end_time = #{final_end_time}")
      $time = $time.last(10)
      num = 0
      while num <= 9
        puts($time[num])
        num += 1
      end
    end

    private

    def set_federation_activity
      @activity = Activity.find_by!(actor_id: params[:actor_id], id: params[:id])
    end

    def activity_params
      params.fetch(:activity, {})
    end

    def split_request
      payload_string = request.body.read
      request.body.rewind if request.body.respond_to? :rewind
      puts("payload_string = #{payload_string}")
      payload_string = payload_string.split("|")
      payload_string
    end

    def payload_from_params(var)
#      puts("test")
#      payload_string = request.body.read
#      payload_string = payload_string.split(",")
#      request.body.rewind if request.body.respond_to? :rewind
#      puts("payload_string = #{payload_string}")
#      if payload_string['to'].include?('http://192.168.2.106:3000/federation/actors/1/inbox'
      begin
        puts(var)
        puts("ここにきてほしい!")
        payload = JSON.parse(var)
#          File.open(payload.object) do |file|
#          hash = JSON.load(file)
#          p hash
#        end
      rescue JSON::ParserError
        return
      end

      hash = JSON::LD::API.compact payload, payload['@context']
      validate_payload hash
      url = hash['object']
      p url
      json = JSON.parse( open(url).read )
      p json
    end

    def validate_payload(hash)
#      puts("hash = #{hash})
      return unless hash['@context'] && hash['id'] && hash['type'] && hash['actor'] && hash['object'] && hash['to']
      hash
    end
  end
end

