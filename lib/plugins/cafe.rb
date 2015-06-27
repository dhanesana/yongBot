require 'nokogiri'
require 'open-uri'

class Cafe
  include Cinch::Plugin

  match /(cafe)$/, prefix: /^(\.)/
  match /(cafe) (.+)/, method: :with_num, prefix: /^(\.)/
  match /(help cafe)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    page = Nokogiri::HTML(open('http://top.cafe.daum.net/_c21_/category_list?type=sub&subcateid=85&cateid=5'))
    total = page.css('td.cafename').size
    title = page.css('td.cafename')[0].children[1].text
    url_array = page.css('td.cafename a.cafeinfo').map { |link| link['href'] }
    score = page.css('td.score')[0].text
    m.reply "Cafe Rank 1: #{title} #{url_array[0]} 점수: #{score}"
  end

  def with_num(m, command, cafe, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    page = Nokogiri::HTML(open('http://top.cafe.daum.net/_c21_/category_list?type=sub&subcateid=85&cateid=5'))
    total = page.css('td.cafename').size
    title = page.css('td.cafename')[num.to_i - 1].children[1].text
    url_array = page.css('td.cafename a.cafeinfo').map { |link| link['href'] }
    score = page.css('td.score')[num.to_i - 1].text
    m.reply "Rank #{num}: #{title} #{url_array[num.to_i - 1]} 점수: #{score}"
  end

  def help(m)
    m.reply 'returns artist/group at specified cafe rank (http://goo.gl/MKg9ia)'
  end

end
