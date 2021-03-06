class Task < ActiveRecord::Base
  belongs_to :user

  def self.scrape_from_moodle
    User.all.each do |user|
        self.scrape_user_courses(user, false)
    end
  end

  def self.scrape_user_courses(user, scrape_all_courses)
    sms_fu = SMSFu::Client.configure(:delivery => :action_mailer)
    mech = Mechanize.new
    mech.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    page = mech.get('https://moodle.lsus.edu/')
    login_form = page.forms.first
    login_form.username = user.username
    login_form.password = user.pin
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
        if due_date > Time.now || scrape_all_courses
            newTask = Task.find_or_create_by(name: name, start_time: due_date, end_time: due_date, notes: notes, user_id: user.id) do |newTask|
                formatted_due_date = due_date.strftime("%A, %b %e %I:%M %p")
                message = "A new assignment was just scraped from moodle:\nclass: #{class_name}\ndue date: #{formatted_due_date}\nassignment: #{assignment_text}"
                sms_fu.deliver(user.phone_number, user.carrier, message)
                unless user.token.nil? 
                    due_date -= 5.hours
                    @event = {
                      'summary' => class_name,
                      'description' => assignment_text,
                      'location' => 'LSUS',
                      'start' => { 'dateTime' => due_date.strftime("%Y-%m-%dT%H:%M:%S"),
                                   'timeZone' => 'America/Chicago' }, 
                      'end' => { 'dateTime' => due_date.strftime("%Y-%m-%dT%H:%M:%S"),
                                 'timeZone' => 'America/Chicago' } }

                    client = Google::APIClient.new
                    client.authorization.access_token = user.token
                    service = client.discovered_api('calendar', 'v3')

                    results = client.execute!(:api_method => service.events.insert,
                                            :parameters => {'calendarId' => user.email, 'sendNotifications' => true},
                                            :body_object => @event)
                    event = results.data
                    puts "Event created: #{event.htmlLink}"
                end
            end
            newTask.save
        end
    end
  end

end
