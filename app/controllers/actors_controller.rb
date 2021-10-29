class ActorsController < ApplicationController
  before_action :set_actor, only: [:show]

  def index
    @actors = policy_scope Actor.all
  end

  def show; end

  def lookup
    @actor = Actor.find_by_account account_param
    authorize @actor
    render :show
  end
 
  private

  def set_actor
    @actor = Actor.find(params[:id])
    authorize @actor
  end

  def account_param
    params.require('account')
  end
end
