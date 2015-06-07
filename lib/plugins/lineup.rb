require 'httparty'

class Lineup
  include Cinch::Plugin

  match /(lineup)/, prefix: /^(\.)/
  match /(help lineup)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    m.reply HTTParty.get('https://yongchicken.herokuapp.com/lineup').body
  end

  def help(m)
    m.reply "returns today/tonight's music show lineup (manually updated)"
  end

end
