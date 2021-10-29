class UserPolicy < ApplicationPolicy
  def show?
#    @record.confirmed?
  end

  def edit?
    update?
  end

  def update?
    @user&.id == @record.id
  end

  class Scope < Scope
    def resolve
 #     scope.confirmed
    end
  end
end

