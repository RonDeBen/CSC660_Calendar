class Task < ActiveRecord::Base

  def self.scrape_from_moodle
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
        notes = "#{nok.css('.course a').text}\n#{nok.css('p').first.text}"
        date = nok.css('.current').text
        time = nok.css('.dimmed_text').text

        due_date = Time.strptime("#{date} #{time}",  "%A, %B %d, %Y %l:%M %p")
        newTask = Task.find_or_create_by(name: name, start_time: due_date, end_time: due_date, notes: notes)
    end
  end

end
