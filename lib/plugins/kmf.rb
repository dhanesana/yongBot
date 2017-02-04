require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'time'

module Cinch
  module Plugins
    class Kmf
      include Cinch::Plugin

      match /(kmf)$/
      match /(kmf) (.+)/, method: :with_sect
      match /(help kmf)$/, method: :help

      def execute(m)
        page = Nokogiri::HTML(open('http://ktmf.koreatimes.com/?page_id=867'))
        lineup = []
        page.css('tr td').first.css('p').each do |act|
          next if act.text == ''
          act_name = act.text
          act_name.slice!(',')
          lineup << act_name
        end
        year = page.css('dt span').first.text
        m.reply "KMF #{year}: #{lineup.join(', ')}"
      end

      def with_sect(m, prefix, kmf, sect)
        input_array = sect.split(/[[:space:]]/)
        input = input_array.join(' ').downcase
        section = "  #{input}".downcase
        agent = Mechanize.new
        agent.get("https://ticket.koreatimes.com/member/login.html") do |page|
          # LOGIN
          login_page = page.form_with(:action => '/member/member_login_process.html?bURL=') do |form|
            username_field = form.field_with(:name => "login_id")
            username_field.value = ENV['KMF_LOGIN']
            password_field = form.field_with(:name => "login_password")
            password_field.value = ENV['KMF_PW']
            form.submit
          end
        end
        year = (Time.now.utc + Time.zone_offset('PDT')).strftime("%Y")
        event_num = (year.to_i - 2000 + 5).to_s
        event_string = event_num.size > 2 ? event_num : '0' + event_num
        agent.get("https://ticket.koreatimes.com/ticket_#{year}/ticket.php?event_id=EV#{event_string}")
        count = 0
        agent.page.parser.css('table#Table_01').first.css('tr td').each do |td|
          count += 1 if td.text.split(/[[:space:]]/).join(' ').downcase != section
          break if td.text.split(/[[:space:]]/).join(' ').downcase == section
        end
        return m.reply "invalid section bru" if count % 8 > 0
        row = (count / 8) + 5
        m.reply agent.page.parser.css('td font')[row].text
      end

      def help(m)
        m.reply 'returns recent/upcoming lineup for korea times music festival'
        m.reply 'returns ticket availability if section is specified'
      end

    end
  end
end
