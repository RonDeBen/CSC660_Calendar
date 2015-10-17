class Task < ActiveRecord::Base

  def self.scrape_from_moodle
    User.all.each do |user|
        scrape_user_courses(user)
    end
  end

  def self.scrape_user_courses(user)
    sms_fu = SMSFu::Client.configure(:delivery => :pony, :pony_config => { :via => :sendmail })
    mech = Mechanize.new
    mech.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    page = mech.get('https://moodle.lsus.edu/')
    login_form = page.forms.first
    login_form.username = 'r10003101'
    login_form.password = '1951'
    result_page = login_form.submit
    calendar_link = result_page.links_with(text: "Go to calendar").first
    calendar_page = calendar_link.click
    calendar_links = calendar_page.links_with(href: /^.*#event.*$/)
    calendar_links.each do |link|
        link_page = link.click
        nok = Nokogiri::HTML(link_page.content)

        name = nok.css('.referer a').text
        class_name = nok.css('.course a').text
        assignment_text = nok.css('p').first.text
        notes = "#{class_name}\n#{assignment_text}"
        date = nok.css('.current').text
        time = nok.css('.dimmed_text').text
        if time.empty?
            time = nok.css('.date').text
        end

        due_date = DateTime.strptime("#{date} #{time}",  "%A, %B %d, %Y %l:%M %p")
        due_date += 5.hours
        if due_date > Time.now
            newTask = Task.find_or_create_by(name: name, start_time: due_date, end_time: due_date, notes: notes, user_id: user.id) do |newTask|
                formatted_due_date = due_date.strftime("%A, %b %e %I:%M %p")
                message = "A new assignment was just scraped from moodle:\nclass: #{class_name}\ndue date: #{formatted_due_date}\nassignment: #{assignment_text}"
                sms_fu.deliver(user.phone_number, user.carrier, message)
            end
            newTask.save
        end
    end
  end

end
