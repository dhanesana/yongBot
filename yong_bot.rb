require 'cinch'
require_relative 'bin/plugins'

yong_bot = Cinch::Bot.new do
  configure do |c|
    c.server = "#{ENV['SERVER']}"
    c.channels = ["#{ENV['CHANNELS']}"]
    c.nicks = ["#{ENV['NICKS']}"]
    c.realname = "yongBot v1.0"

    c.plugins.plugins = [
      Help,
      Lineup,
      Iono,
      Roll,
      Rollu,
      Woll,
      Gn,
      Bingul,
      Yongpop,
      Omg,
      Lovelyz,
      Ig,
      Kmodel,
      Sub,
      Tumblr,
      Flickr,
      Nba,
      Melon,
      Mwave,
      Cpme,
      Yomama,
      Pokemon,
      Cafe,
      Naver,
      Daum,
      Eat,
      Dispatch,
      Face,
      Vine,
      Ign,
      Steam,
      Sc,
      Celeb,
      Wutdis,
      ThisOrThat
    ]
  end

  on :message, ".thyme" do |m|
    t = Time.now
    m.reply "#{t} UTC"
  end

end

yong_bot.start
