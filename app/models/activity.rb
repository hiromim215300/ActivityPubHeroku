class Activity < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :actor

  scope :feed_for, lambda { |actor|
    actor_ids = []
    #Following.accepted.where(actor: actor).find_each do |following|
     # actor_ids << following.target_actor_id
    #end
    where(actor_id: actor_ids)
  }

  after_create_commit :post_to_inboxes

  def recipients # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    return [] unless actor.local?

    actors = []
    case action
    when 'Create'
      puts("actors.push")
     # actors.push('http://192.168.2.100:3000/notes/3.json') if entity_type == 'Note'
    end
    actors
  end

  private

  def post_to_inboxes
    NotifyInboxJob.perform_later(self)
  end
end
