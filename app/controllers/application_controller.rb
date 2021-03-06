class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # locale setting
  # ref. http://ruby-rails.hatenadiary.com/entry/20150226/1424937175
  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  def default_url_options(options = {})
    {locale: I18n.locale}.merge options
  end

  helper_method :current_user
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end

