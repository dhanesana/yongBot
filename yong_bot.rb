require 'cinch'
require_relative 'bin/plugins'

yong_bot = Cinch::Bot.new do
  configure do |c|
    c.server = "#{ENV['SERVER']}"
    c.channels = [
      "#{ENV['CHANNEL_1']}",
      "#{ENV['CHANNEL_2']}",
      "#{ENV['CHANNEL_3']}"
    ]
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
      ThisOrThat,
      # Thestudio,
      Kst,
      Buzz,
      Meet,
      Wshh
    ]
  end

  on :message, ".thyme" do |m|
    t = Time.now
    m.reply "#{t}"
  end

end

yong_bot.start
