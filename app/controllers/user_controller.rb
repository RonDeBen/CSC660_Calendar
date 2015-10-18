class UserController < ApplicationController

  def user_params
    params.require(:user).permit(:email, :username, :pin, :phone_number, :carrier)
  end
end
