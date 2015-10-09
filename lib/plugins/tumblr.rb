require 'httparty'
require 'open-uri'

class Tumblr
  include Cinch::Plugin

  match /(tumblr) (.+)/, prefix: /^(\.)/
  match /(help tumblr)$/, method: :help, prefix: /^(\.)/


  def execute(m, prefix, tumblr, tag)
    query = tag.split(/[[:space:]]/).join(' ').downcase
    response = HTTParty.get("http://api.tumblr.com/v2/blog/#{URI.encode(query)}.tumblr.com/posts/photo?api_key=#{ENV['TUMBLR_KEY']}")
    post = []
    response['response']['posts'].first['photos'].each do |pic|
      post << pic['original_size']['url']
    end
    m.reply post.join(', ')
  end

  def help(m)
    m.reply 'returns most recent photo post from specified tumblr user'
  end

end
