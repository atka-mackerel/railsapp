class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :store_location
  before_action :current_user
  before_action :login_required
  after_action :delete_location
  helper_method :current_user

  private

    def store_location
      session[:location] = request.url
      pp session[:location]
    end

    def redirect_path
      session[:location] || root_path
    end

    def delete_location
      session.delete(:location)
    end
    

    def current_user
      @current_user ||= User.find_by(login_id: session[:login_id]) if session[:login_id]
    end

    def login_required
      redirect_to login_path unless @current_user
    end

    def handle_errors(*errors, model: nil)
      @errors ||= []
      @errors.concat(errors) if errors.any?
      @errors.concat(model.errors.full_messages) if model&.errors&.any?
    end
end
