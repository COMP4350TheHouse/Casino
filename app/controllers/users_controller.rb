# This class handles the logic for user account creation, and viewing user information
class UsersController < ApplicationController
  STARTING_BALANCE = 1000.00

  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to users_new_path, alert: "Try again later." }

  before_action :user_from_params, only: %i[create]

  def new
    @user = User.new
  end

  def create
    begin
      @user.save!
    rescue ActiveRecord::RecordInvalid => e
      # Send error message to frontend
      flash[:alert] = e.record.errors.objects.first.full_message
      render :new, status: :unprocessable_entity
      return
    end

    # Start new session after creating account
    if (user = User.authenticate_by(auth_params))
      start_new_session_for user
    end

    redirect_to after_authentication_url
  end

  def show
    if Current.session.user.username == params[:id]
      @user = User.find_by username: params[:id]
    else
      redirect_to root_url
    end
  end

  private

  def user_from_params
    @user = User.new(user_params)
    @user.balance = STARTING_BALANCE
  end

  def user_params
    params.expect(user: [:email_address, :username, :password, :password_confirmation])
  end

  def auth_params
    params.expect(user: [:email_address, :password])
  end
end
