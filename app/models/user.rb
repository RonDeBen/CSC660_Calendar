class User < ActiveRecord::Base
  has_many :tasks

  after_create :scrape_my_courses

  def scrape_my_courses
    Task.scrape_user_courses(self)
  end
end
