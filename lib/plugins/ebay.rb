require 'open-uri'
require 'unirest'

class Ebay
  include Cinch::Plugin

  match /(ebay) (.+)/, prefix: /^(\.)/
  match /(help ebay)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, ebay, term)
    query = term.split(/[[:space:]]/).join(' ').downcase
    response = Unirest.get(
      "http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByKeywords&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=#{ENV['EBAY_ID']}&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&keywords=#{URI.encode(query)}"
    )
    return 'failed search bru' if response.body['findItemsByKeywordsResponse'].first['ack'].first == 'Failure'
    return 'no results match ur search bru' if response.body['findItemsByKeywordsResponse'].first['searchResult'].first['@count'] == '0'
    title = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['title'].first
    buy_url = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['viewItemURL'].first
    price = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['sellingStatus'].first['currentPrice'].first['__value__']
    currency = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['sellingStatus'].first['currentPrice'].first['@currencyId']
    m.reply "#{title} | #{price} #{currency} | #{buy_url}"
  end

  def help(m)
    m.reply 'searches ebay and returns the first result'
  end

end
