class UsersController < ApplicationController
  skip_before_action :login_required

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path, notice: t('.success')
    else
      handle_errors(model: @user)
      render :new
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :login_id, :password, :password_confirmation)
    end
end
