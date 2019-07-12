class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :login_required
  helper_method :current_user

  private

    def current_user
      @current_user ||= User.find_by(login_id: session[:login_id]) if session[:login_id]
    end

    def login_required
      redirect_to login_path unless current_user
    end

    def handle_errors(*errors, model: nil)
      @errors ||= []
      @errors.concat(errors) if errors.any?
      @errors.concat(model.errors.full_messages) if model&.errors&.any?
    end
end
