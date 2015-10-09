require 'open-uri'
require 'unirest'
require 'nokogiri'

class Ebay
  include Cinch::Plugin

  match /(ebay) (.+)/, prefix: /^(\.)/
  match /(store) (.+)/, method: :store, prefix: /^(\.)/
  match /(help ebay)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, ebay, term)
    query = term.split(/[[:space:]]/).join(' ').downcase
    response = Unirest.get(
      "http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByKeywords&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=#{ENV['EBAY_ID']}&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&keywords=#{URI.encode(query)}"
    )
    return m.reply 'failed search bru' if response.body['findItemsByKeywordsResponse'].first['ack'].first == 'Failure'
    return m.reply 'no results match ur search bru' if response.body['findItemsByKeywordsResponse'].first['searchResult'].first['@count'] == '0'
    title = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['title'].first
    buy_url = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['viewItemURL'].first
    price = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['sellingStatus'].first['currentPrice'].first['__value__']
    currency = response.body['findItemsByKeywordsResponse'].first['searchResult'].first['item'].first['sellingStatus'].first['currentPrice'].first['@currencyId']
    m.reply "#{title} | #{price} #{currency} | #{buy_url}"
  end

  def store(m, prefix, store, search)
    query_array = search.split(/[[:space:]]/).join(' ').downcase.split(' ')
    user_id = query_array.first
    query_array.delete_at(0)
    query = query_array.join(' ')
    response = Nokogiri::XML(open(
      "http://open.api.ebay.com/shopping?callname=GetUserProfile&responseencoding=XML&appid=#{ENV['EBAY_ID']}&version=525&&RESPONSE-DATA-FORMAT=JSON&UserID=#{user_id}&IncludeSelector=Details"
    ))
    store_name = response.search('StoreName').text
    store_name = user_id if store_name == ""
    search_store = Unirest.get(
      "http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsIneBayStores&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=#{ENV['EBAY_ID']}&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&storeName=#{store_name}&keywords=#{URI.encode(query)}"
    )
    return m.reply "invalid userid or user doesn't have a store" if search_store.body['findItemsIneBayStoresResponse'].first['ack'].first == 'Failure'
    count = search_store.body['findItemsIneBayStoresResponse'].first['searchResult'].first['@count'].to_i
    return m.reply '0 items found bru' if count < 1
    title = search_store.body['findItemsIneBayStoresResponse'].first['searchResult'].first['item'].first['title'].first
    buy_url = search_store.body['findItemsIneBayStoresResponse'].first['searchResult'].first['item'].first['viewItemURL'].first
    price = search_store.body['findItemsIneBayStoresResponse'].first['searchResult'].first['item'].first['sellingStatus'].first['currentPrice'].first['__value__']
    currency = search_store.body['findItemsIneBayStoresResponse'].first['searchResult'].first['item'].first['sellingStatus'].first['currentPrice'].first['@currencyId']
    m.reply "#{title} | #{price} #{currency} | #{buy_url}"
  end

  def help(m)
    m.reply 'searches ebay and returns the first result.'
    m.reply ".store [user_id or store_name] [query] to search stores. user_id must have an ebay store to search"
  end

end
