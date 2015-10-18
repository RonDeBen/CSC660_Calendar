class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable,
         :trackable, :omniauthable, :omniauth_providers => [:google_oauth2]
  has_many :tasks

  after_create :scrape_my_tasks

  before_destroy :destroy_tasks

  def scrape_my_tasks
    Task.scrape_user_courses(self)
  end

  def test_message
    sms_fu = SMSFu::Client.configure(:delivery => :action_mailer)
    sms_fu.deliver(self.phone_number, self.carrier, "test")
  end

  private

  def destroy_tasks
    self.tasks.destroy_all
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    if (User.admins.include?(data.email))
      user = User.find_by(email: data.email)
      if user
        user.provider = access_token.provider
        user.uid = access_token.uid
        user.token = access_token.credentials.token
        user.save
        user
      else
        redirect_to new_user_registration_path, notice: "Error."
      end
    end
  end

end
