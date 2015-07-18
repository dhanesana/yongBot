require 'unirest'
require 'open-uri'

class Trans
  include Cinch::Plugin

  match /(trans) (.+)/, prefix: /^(\.)/
  match /(help trans)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, trans, sentence)
    string = URI.encode(sentence)
    response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{string}&target=en")
    translated = response.body['data']['translations'].first['translatedText']
    source_lang = response.body['data']['translations'].first['detectedSourceLanguage']
    m.reply "Language: #{source_lang.upcase} => #{translated}"
  end

  def help(m)
    m.reply 'returns english-translated text'
  end

end
