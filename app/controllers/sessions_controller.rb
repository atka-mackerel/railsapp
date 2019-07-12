class SessionsController < ApplicationController
  skip_before_action :login_required

  # Login page
  def new
    @user = User.new
  end

  # Login proccess
  def create
    @user = User.find_by(login_id: user_params[:login_id])
    if @user&.authenticate(user_params[:password])
      session[:login_id] = @user.login_id
      redirect_to memos_path
    else
      handle_errors(t('.auth_failed'))
      @user = User.new
      render :new, status: :unauthorized
    end
  end

  # Logout proccess
  def destroy
    reset_session
    redirect_to login_path, notice: t('.success')
  end

  private

    def user_params
      params.require(:user).permit(:login_id, :password, :password_confirmation)
    end
end
