class Roll
  include Cinch::Plugin

  match /(roll)$/, prefix: /^(\.)/
  match /(help roll)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    m.reply "[ #{rand(1..6)} ] [ #{rand(1..6)} ]"
  end

  def help(m)
    m.reply "dice rollllll"
  end

end
