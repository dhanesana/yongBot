require 'cinch'
require 'cinch/plugins/identify'
require_relative 'bin/plugins'

$master = "#{ENV['MASTER']}"

yong_bot = Cinch::Bot.new do
  configure do |c|
    c.server = "#{ENV['SERVER']}"
    c.channels = ["#{ENV['CHANNELS']}"]
    c.nicks = ["#{ENV['NICKS']}"]
    c.realname = "yongBot v1.0"
    c.user = "yongBot"

    c.plugins.plugins = [
      Cinch::Plugins::Identify,
      Master,
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
      Kst,
      Buzz,
      Meet,
      Wshh,
      Instiz,
      Gaon,
      Fresh,
      Agb,
      Tnms,
      Lyric,
      Simply,
      Asc,
      Csgo,
      Kpoppin,
      Github,
      Soundk,
      Viki,
      Now,
      Trans,
      Ud,
      Twins,
      Sh,
      Poll,
      Kwikia,
      Wa,
      Ebay,
      Twitch,
      Kquiz,
      Genie,
      Olleh,
      Mnet,
      Log,
      Powerball,
      FacePlus,
      Romanize,
      Nfl
    ]
    c.delay_joins = :identified
    c.plugins.options[Cinch::Plugins::Identify] = {
      :username => "#{ENV['NICKS']}",
      :password => "#{ENV['PW']}",
      :type     => :nickserv,
    }
  end
end

yong_bot.start
