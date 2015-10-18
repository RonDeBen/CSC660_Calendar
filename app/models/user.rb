class User < ActiveRecord::Base
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
end
