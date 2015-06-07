require 'nokogiri'
require 'open-uri'

class Thestudio
  include Cinch::Plugin

  match /(kstudio)$/, prefix: /^(\.)/
  match /(help kstudio)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    page = Nokogiri::HTML(open('http://thestudio.kr/'))
    title = page.css('ul#navlist li p a')[31].text
    href = page.css('ul#navlist li p a')[31]['href']
    m.reply "#{title}: http://thestudio.kr#{href}"
  end

  def help(m)
    m.reply 'returns most recent thestudio.kr post'
  end

end
