class ActorPolicy < ApplicationPolicy
  def lookup?
    true
  end

  class Scope < Scope
    def resolve
      scope.local
    end
  end
end

