require 'nokogiri'
require 'open-uri'

class Thestudio
  include Cinch::Plugin

  match /(studio)$/, prefix: /^(\.)/
  match /(help studio)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    page = Nokogiri::HTML(open('http://thestudio.kr/'))
    title = page.css('p.tt-post-title.tt-clear a')[rand(1..29)].text
    href = page.css('p.tt-post-title.tt-clear a')[rand(1..29)]['href']
    m.reply "#{title}: http://thestudio.kr#{href}"
  end

  def help(m)
    m.reply 'returns random recent thestudio.kr post'
  end

end
