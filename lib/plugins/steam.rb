require 'nokogiri'
require 'json'
require 'open-uri'
require 'time'

module Cinch
  module Plugins
    class Steam
      include Cinch::Plugin

      match /(steam) (.+)/
      match /(help steam)$/, method: :help

      def execute(m, prefix, steam, user)
        page = Nokogiri::XML(open("http://steamcommunity.com/id/#{user}/?xml=1"))
        return m.reply "invalid user bru" if page.text == "The specified profile could not be found."
        steamID64 = page.xpath("//steamID64").text
        steamGet = open("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_KEY']}&steamids=#{steamID64}").read
        result = JSON.parse(steamGet)
        logoff = result['response']['players'].first['lastlogoff']
        url = URI.encode(result['response']['players'].first['profileurl'])
        avatar = result['response']['players'].first['avatarfull']
        normalTime = Time.at(logoff).utc + Time.zone_offset('PDT')
        lastSeen = normalTime.strftime("%Y-%m-%d %I:%M%P PDT")
        username = result['response']['players'].first['personaname']
        state_num = result['response']['players'].first['personastate']

        status = 'Offline or Private' if state_num == 0
        status = 'Online'             if state_num == 1
        status = 'Busy'               if state_num == 2
        status = 'Away'               if state_num == 3
        status = 'Snooze'             if state_num == 4
        status = 'Looking to Trade'   if state_num == 5
        status = 'Looking to Play'    if state_num == 6

        logoff_string = ''
        logoff_string = " | Logged Off: #{lastSeen} " if state_num == 0

        gamesGet = JSON.parse(open("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{ENV['STEAM_KEY']}&steamid=#{steamID64}&format=json").read)['response']
        game_count = gamesGet['game_count']

        m.reply "#{username} | Games: #{game_count} | Status: #{status}#{logoff_string} | #{url}"
      end

      def help(m)
        m.reply 'Returns game count, current status, and url for specified public Steam username'
      end

    end
  end
end
