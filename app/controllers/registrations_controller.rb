class RegistrationsController < Devise::RegistrationsController

  protected

  def after_sign_up_path_for(resource)
    'omniauth_callbacks#google_oauth2'
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :username, :pin, :phone_number, :carrier)
  end

  def account_update_params
    params.require(:user).permit(:email, :username, :pin, :phone_number, :carrier)
  end
end