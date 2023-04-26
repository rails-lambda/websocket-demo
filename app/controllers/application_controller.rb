class ApplicationController < ActionController::Base
  before_action :require_current_user
  helper_method :current_user
  
  def index
    redirect_to rooms_url if current_user
  end

  def login
    session[:user_name] = Faker::Name.name
    redirect_to rooms_url
  end

  def logout
    session.clear
    redirect_to root_url
  end

  private

  def current_user
    User.find(current_user_name) if current_user_name
  end

  def current_user_name
    session[:user_name]
  end

  def require_current_user
    return if controller_name == 'application'
    redirect_to root_url unless current_user
  end
end
