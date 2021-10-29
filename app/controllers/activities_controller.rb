class ActivitiesController < ApplicationController
  before_action :authenticate_user!, only: [:feed]  

  def index
    @activities = policy_scope Activity.all
    @activities = @activities.where actor_id: params[:actor_id] if params[:actor_id]
  end

  def feed
    @activities = Activity.feed_for(current_user.actor)
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
