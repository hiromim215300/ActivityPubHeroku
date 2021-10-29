class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true, format: { with: /[a-z0-9\-_]{3,}/i }

  has_one :actor, dependent: :destroy

#  scope :confirmed, -> { where.not(confirmed_at: nil) }
  before_create :create_name
  after_create :create_actor

  def create_name
    self.name = "@#{username}"
  end

#  def confirmed?
 #   confirmed_at.present?
 # end

  private

  def create_actor
    Actor.create! user: self
  end
end
