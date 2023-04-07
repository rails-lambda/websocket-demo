class ApplicationController < ActionController::Base
  helper_method :current_user
  
  def index
    redirect_to rooms_url if current_user
  end

  def login
    session[:user] = Faker::Name.name
    redirect_to rooms_url
  end

  def logout
    session.delete(:user)
    redirect_to root_url
  end

  private
  def current_user
    session[:user]
  end
end
  