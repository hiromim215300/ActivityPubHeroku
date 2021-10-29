class ApplicationController < ActionController::Base
  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?
#  skip_before_action :verify_authenticity_token, if: :json_request?

  rescue_from ActiveRecord::RecordNotFound, with: :error_not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :error_csrf
  rescue_from ActionController::ParameterMissing, with: :error_unprocessable
  rescue_from Pundit::NotAuthorizedError, with: :error_not_authorized

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:  [:username, :name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def error_fallback(exception, fallback_message, status)
    message = exception&.message || fallback_message
    respond_to do |format|
      format.json { render json: { error: message }, status: status }
      format.html { raise exception }
    end
  end

  def error_not_found(exception = nil)
    
  end

  def error_unprocessable(exception = nil)
    #error_fallback(exception, I18n.t('controller.application.error_unprocessable.error'), :unprocessable_entity)
  end

  def error_csrf(exception = nil)
    #error_fallback(exception, I18n.t('controller.application.error_csrf.error'), :unprocessable_entity)
  end

  def error_not_authorized(exception = nil)
   # message = I18n.t('controller.application.error_not_authorized.error')
  #  respond_to do |format|
   #   format.json { render json: { error: message }, status: :unauthorized }
    #  format.html do
     #   # User is signed in but don't have the rights to perform the action
     #   raise exception if current_user.present?

    #    redirect_to new_user_session_path
     # end
   # end
  end

  def json_request?
    request.format.json?
  end

end
