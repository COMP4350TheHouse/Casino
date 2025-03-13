class ApplicationController < ActionController::Base
  include Authentication
  before_action :set_current_path, :current_session
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?, :on_lobby_page?, :on_horse_racing?, :current_session

  def current_session
    @session = Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def current_user
    @current_user ||= current_session.user
  end

  def logged_in?
    current_session
  end

  def set_current_path
    @current_path = request.path
  end

  def on_lobby_page?
    @current_path == '/'
  end

  def on_horse_racing?
    @current_path == horse_race_index_path
  end
end
