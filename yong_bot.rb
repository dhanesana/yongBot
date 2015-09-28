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
      Log
    ]
    c.delay_joins = :identified
    c.plugins.options[Cinch::Plugins::Identify] = {
      :username => "#{ENV['NICKS']}",
      :password => "#{ENV['PW']}",
      :type     => :nickserv,
    }
  end

  on :message, ".thyme" do |m|
    m.reply Time.now.strftime("%Y-%m-%d %H:%M %Z")
  end

  helpers do
    def is_admin?(user)
      true if user.nick == $master
    end
  end

  on :message, /^.join (.+)/ do |m, channel|
    bot.join(channel) if is_admin?(m.user)
  end

  on :message, /^.part(?: (.+))?/ do |m, channel|
    # Part current channel if none is given
    channel = channel || m.channel

    if channel
      bot.part(channel) if is_admin?(m.user)
    end
  end

  on :message, /^.setnick (.+)/ do |m, name|
    if is_admin?(m.user)
      return @bot.nick = name
    else
      m.reply "https://youtu.be/OBWpzvJGTz4"
    end
  end

  on :message, ".ping" do |m|
    ops = Channel(m.channel.name).ops.map { |x| x.nick }
    if ops.include? m.user.nick || is_admin?(m.user)
      users = []
      Channel(m.channel.name).users.each do |user|
        users << user.first.nick
      end
      users.delete(@bot.nick)
      m.reply users.join(' ')
    else
      m.reply 'sry ops only'
    end
  end

end

yong_bot.start
