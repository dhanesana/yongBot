require 'nokogiri'
require 'json'
require 'open-uri'

class Csgo
  include Cinch::Plugin

  match /(csgo) (.+)/, prefix: /^(\.)/
  match /(help csgo)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, csgo, user)
    page = Nokogiri::XML(open("http://steamcommunity.com/id/#{user}/?xml=1"))
    return m.reply "invalid user bru" if page.text == "The specified profile could not be found."
    steamID64 = page.xpath("//steamID64").text
    steamGet = open("http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002/?appid=730&key=#{ENV['STEAM_KEY']}&steamid=#{steamID64}").read
    result = JSON.parse(steamGet)

    total_k = result['playerstats']['stats'].first['value'].to_f
    total_d = result['playerstats']['stats'][1]['value'].to_f
    kd_ratio = (total_k / total_d).round(2)

    hs = result['playerstats']['stats'][20]['value'].to_f
    hs_ratio = ((hs / total_k) * 100).round(0)

    hit = result['playerstats']['stats'][31]['value'].to_f
    fired = result['playerstats']['stats'][32]['value'].to_f
    accuracy = ((hit / fired) * 100).round(0)

    wins = result['playerstats']['stats'][5]['value'].to_f
    total_matches = result['playerstats']['stats'][33]['value'].to_f
    win_ratio = ((wins / total_matches) * 100).round(0)

    m.reply "K/D: #{kd_ratio} | HS: #{hs_ratio}% | ACC: #{accuracy}% | WIN: #{win_ratio}%"
  end

  def help(m)
    m.reply 'Returns K/D ratio, hs percentage, accuracy, and win percentage for specified public Steam username'
  end

end
