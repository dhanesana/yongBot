require 'nokogiri'
require 'open-uri'

class Wa
  include Cinch::Plugin

  match /(wa) (.+)/, prefix: /^(\.)/
  match /(help wa)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, wa, text)
    input_array = text.split(/[[:space:]]/)
    input = input_array.join(' ').downcase
    response = Nokogiri::XML(open("http://api.wolframalpha.com/v2/query?input=#{URI.encode(input)}&appid=#{ENV['WA_ID']}"))
    interp = response.xpath('//plaintext').children[0].text.split(/[[:space:]]/).join(' ')
    if interp.size > 75
      interp.slice! 75..-1
      interp += "..."
    end
    result = response.xpath('//plaintext').children[1].text.split(/[[:space:]]/).join(' ')
    if result.size > 75
      result.slice! 75..-1
      result += "..."
    end
    m.reply "#{interp} => #{result}"
  end

  def help(m)
    m.reply 'Sends a query to wolfram alpha and returns a result'
  end

end
