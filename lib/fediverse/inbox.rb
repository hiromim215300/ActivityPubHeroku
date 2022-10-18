require 'fediverse/request'

module Fediverse
  class Inbox
    class << self
      def dispatch_request(payload)
        puts("dispatch_request始まるよだが何かがおかしい")
        puts("ここでのpayload_typeは#{payload['type']}")
        case payload['type']
#          puts("ここでのpayloadは#{payload}")
        when 'Note'
          puts ("Begin Create 1")
          handle_create_request payload
         # actor = Actor.find_or_create_by_object activity['attributedTo']
         # Activity.create! entity_type: "Note", action: "Create"
        when 'Accept'
          handle_accept_request payload
        when 'Undo'
          handle_undo_request payload
        else
          # FIXME: Fails silently
          # raise NotImplementedError
          puts ("Begin Create 2")
          handle_create_request payload
         # actor = Actor.find_or_create_by_object activity['attributedTo']
         # Activity.create! entity_type: "Note", action: "Create"
#          Rails.logger.debug "Unhandled activity type: #{payload['type']}"
        end
      puts("ここはどうかしら")
      end

      private

      def handle_create_request(payload)
#        activity = Request.get(payload['object'])
#       activity = Request.get(payload['type'])
       puts("handle create request payload 始めます#{payload['type']}")
        case payload['type']
        when 'Follow'
          handle_create_follow_request payload
        when 'Note'
         puts("今ここ") 
         handle_create_note payload
#          puts("Note")
        end
      end

      def handle_create_follow_request(activity)
        actor        = Actor.find_or_create_by_object activity['actor']
        target_actor = Actor.find_or_create_by_object activity['object']

        Following.create! actor: actor, target_actor: target_actor, federated_url: activity['id']
      end

      def handle_create_note(payload)
        puts("handle_create_note")
        actor = Actor.find_or_create_by_object payload['attributedTo']
        puts("handle_create_noteでのactor = #{actor}")
        Note.create! actor: actor, content: payload['content'], federated_url: payload['id']
      end

      def handle_accept_request(payload)
        activity = Request.get(payload['object'])
        raise "Can't accept things that are not Follow" unless activity['type'] == 'Follow'

        actor        = Actor.find_or_create_by_object activity['actor']
        target_actor = Actor.find_or_create_by_object activity['object']
        raise 'Follow not accepted by target actor but by someone else' if payload['actor'] != target_actor.federated_url

        follow = Following.find_by actor: actor, target_actor: target_actor
        follow.accept!
      end

      def handle_undo_request(payload)
        activity = Request.get(payload['object'])
        raise "Can't undo things that are not Follow" unless activity['type'] == 'Follow'

        actor        = Actor.find_or_create_by_object activity['actor']
        target_actor = Actor.find_or_create_by_object activity['object']

        follow = Following.find_by actor: actor, target_actor: target_actor
        follow&.destroy
      end
    end
  end
end

