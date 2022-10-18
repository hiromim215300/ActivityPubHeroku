require 'utils/host'
require 'fediverse/webfinger'

class Actor < ApplicationRecord
#  include Routeable
  belongs_to :user, optional: true

#  before_create :c_username
#  before_create :c_name
#  before_create :c_server
#  before_create :c_inbox_url
#  before_create :federated_url
#  before_create :c_outbox_url

  validates :federated_url, presence: { unless: :user_id }, uniqueness: { unless: :user_id }
  validates :username, presence: { unless: :user_id }
  validates :server, presence: { unless: :user_id }
  validates :inbox_url, presence: { unless: :user_id }
  validates :outbox_url, presence: { unless: :user_id }
 # validates :followers_url, presence: { unless: :user_id }
 # validates :followings_url, presence: { unless: :user_id }
  validates :user_id, uniqueness: true, if: :local?

  has_many :notes, dependent: :destroy
  has_many :activities, dependent: :destroy

  scope :local, -> {where.not(user_id: nil) }

 def local?
    user_id.present?
  end

  def federated_url
#    puts("確認用。federated_url")
    url = local? ? federation_actor_url(self) : attributes['federated_url'].presence
#    first = Utils::Host.localhost
 #   second = self.user_id
  #  self.federated_url = "http://#{first}:3000/actors/#{second}"
  end

  def c_username
    username = local? ? user.username : attributes['username']
    self.username = username
  end

  def c_name
    name = local? ? user.name : attributes['name'] || username 
    self.name = name
  end

  def c_server
    server = local? ? Utils::Host.localhost : attributes['server']
    self.server = server
  end

  def c_inbox_url
    #inbox_url = local? ? federation_actor_inbox_url(self) : attributes['inbox_url']
    first = Utils::Host.localhost
    second = self.user_id
    self.inbox_url = "http://#{first}:3000/actors/#{second}/inbox"
  end

  def c_outbox_url
    #local? ? federation_actor_outbox_url(self) : attributes['inbox_url']
    first = Utils::Host.localhost
    second = self.user_id
    self.outbox_url = "http://#{first}:3000/actors/#{second}/outbox"
  end

  def at_address
    "#{username}@#{server}"
  end

  class << self
    def find_by_account(account)
      parts = Fediverse::Webfinger.split_account account
      puts("parts = #{parts}")
      if Fediverse::Webfinger.local_user? parts
        actor = User.find_by!(username: parts[:username]).actor
      else
        actor = find_by username: parts[:username], server: parts[:domain]
        actor ||= Fediverse::Webfinger.fetch_actor(parts[:username], parts[:domain])
      end

      actor
    end

    def find_by_federation_url(federated_url)
      puts("確認用,find_by_federation_url#{federated_url}")
      local_route = Utils::Host.local_route federated_url
      puts("確認用、local_routeよくわからんがlocal_route=#{local_route}")
      return find local_route[:id] if local_route && local_route[:controller] == 'actors' && local_route[:action] == 'show'

      actor = find_by federated_url: federated_url
      puts("ここでのactor=#{actor}")
      actor ||= Fediverse::Webfinger.fetch_actor_url(federated_url)

      puts("actor=#{actor}")
      puts("actor.federated_url=#{actor.federated_url}")
      actor.federated_url = 'http://192.168.2.104:3000/actors/1'
      puts("actor.federated_url=#{actor.federated_url}")
      puts("確認用, actorの中身:federated_url=#{actor.federated_url},name=#{actor.name},server=#{actor.server},inbox_url=#{actor.inbox_url},outbox_url=#{actor.outbox_url}")
      actor
    end

    def find_or_create_by_account(account)
      actor = find_by_account account
      # Create/update distant actors
      puts("nil Class? actor=#{actor}")
      actor.save! unless actor.local?

      actor
    end

    def find_or_create_by_federation_url(url)
      actor = find_by_federation_url url
      # Create/update distant actors
      puts("nil Class? actor=#{actor}")
      actor.save!

      actor
    end

    # Find or create actor from a given actor hash or actor id (actor's URL)
    def find_or_create_by_object(object)
      puts("find_or_create_by_objectです、obeject = #{object}")
      if object.is_a? String
        find_or_create_by_federation_url object
      elsif object.is_a? Hash
        find_or_create_by_federation_url object['id']
      else
        raise "Unsupported object type for actor (#{object.class})"
      end
    end
  end

end
