class User < ActiveRecord::Base
  has_many :tasks

  after_create :scrape_my_courses

  before_destroy :destroy_tasks

  def scrape_my_courses
    Task.scrape_user_courses(self)
  end

  private

  def destroy_tasks
    self.tasks.destroy_all
  end
end
