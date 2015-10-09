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
    interp = response.xpath('//plaintext').children[0]
    result = response.xpath('//plaintext').children[1]
    m.reply "#{interp} => #{result}"
  end

  def help(m)
    m.reply 'Sends a query to wolfram alpha and returns a result'
  end

end
