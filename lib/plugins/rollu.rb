class Rollu
  include Cinch::Plugin

  match /(rollu)$/, prefix: /^(\.)/
  match /(help rollu)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    die_1 = rand(1..6)
    die_2 = rand(1..6)

    k1 = ''
    k1 += '하나' if die_1 == 1
    k1 += '둘' if die_1 == 2
    k1 += '셋' if die_1 == 3
    k1 += '넷' if die_1 == 4
    k1 += '다섯' if die_1 == 5
    k1 += '여섯' if die_1 == 6

    k2 = ''
    k2 += '하나' if die_2 == 1
    k2 += '둘' if die_2 == 2
    k2 += '셋' if die_2 == 3
    k2 += '넷' if die_2 == 4
    k2 += '다섯' if die_2 == 5
    k2 += '여섯' if die_2 == 6

    m.reply "[ #{k1} ] [ #{k2} ]"
  end

  def help(m)
    m.reply "is like .roll but hangulized"
  end

end
