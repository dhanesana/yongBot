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
    c.plugins.prefix = /^(\.)/

    c.plugins.plugins = [
      Cinch::Plugins::Identify,
      Cinch::Plugins::Master,
      Cinch::Plugins::Help,
      Cinch::Plugins::Lineup,
      Cinch::Plugins::Iono,
      Cinch::Plugins::Roll,
      Cinch::Plugins::Rollu,
      Cinch::Plugins::Woll,
      Cinch::Plugins::Gn,
      Cinch::Plugins::Bingul,
      Cinch::Plugins::Yongpop,
      Cinch::Plugins::Omg,
      Cinch::Plugins::Lovelyz,
      Cinch::Plugins::Ig,
      Cinch::Plugins::Kmodel,
      Cinch::Plugins::Sub,
      Cinch::Plugins::Tumblr,
      Cinch::Plugins::Flickr,
      Cinch::Plugins::Nba,
      Cinch::Plugins::Melon,
      Cinch::Plugins::Mwave,
      Cinch::Plugins::Cpme,
      Cinch::Plugins::Yomama,
      Cinch::Plugins::Pokemon,
      Cinch::Plugins::Cafe,
      Cinch::Plugins::Naver,
      Cinch::Plugins::Daum,
      Cinch::Plugins::Eat,
      Cinch::Plugins::Dispatch,
      Cinch::Plugins::Face,
      Cinch::Plugins::Vine,
      Cinch::Plugins::Ign,
      Cinch::Plugins::Steam,
      Cinch::Plugins::Sc,
      Cinch::Plugins::Celeb,
      Cinch::Plugins::Wutdis,
      Cinch::Plugins::Kst,
      Cinch::Plugins::Buzz,
      Cinch::Plugins::Meet,
      Cinch::Plugins::Wshh,
      Cinch::Plugins::Instiz,
      Cinch::Plugins::Gaon,
      Cinch::Plugins::Fresh,
      Cinch::Plugins::Agb,
      Cinch::Plugins::Tnms,
      Cinch::Plugins::Lyric,
      Cinch::Plugins::Simply,
      Cinch::Plugins::Asc,
      Cinch::Plugins::Csgo,
      Cinch::Plugins::Kpoppin,
      Cinch::Plugins::Github,
      Cinch::Plugins::Soundk,
      Cinch::Plugins::Viki,
      Cinch::Plugins::Now,
      Cinch::Plugins::Trans,
      Cinch::Plugins::Ud,
      Cinch::Plugins::Twins,
      Cinch::Plugins::Sh,
      Cinch::Plugins::Poll,
      Cinch::Plugins::Kwikia,
      Cinch::Plugins::Wa,
      Cinch::Plugins::Ebay,
      Cinch::Plugins::Twitch,
      Cinch::Plugins::Kquiz,
      Cinch::Plugins::Genie,
      Cinch::Plugins::Olleh,
      Cinch::Plugins::Mnet,
      Cinch::Plugins::Log,
      Cinch::Plugins::Powerball,
      Cinch::Plugins::FacePlus,
      Cinch::Plugins::Romanize,
      Cinch::Plugins::Nfl,
      Cinch::Plugins::Popsinseoul,
      Cinch::Plugins::Superkpop,
      Cinch::Plugins::Weekly,
      Cinch::Plugins::Choice,
      Cinch::Plugins::Horo,
      Cinch::Plugins::Zodiac,
      Cinch::Plugins::Rm,
      Cinch::Plugins::P101
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
