require 'unidecoder'

class Romanize
  include Cinch::Plugin

  match /(romanize) (.+)/, prefix: /^(\.)/
  match /(help romanize)$/, method: :help, prefix: /^(\.)/

  def execute(m, prefix, romanize, words)
    input = words.split(/[[:space:]]/).join(' ')
    output = input.to_ascii
    if output.size > 225
      output.slice! 225..-1
      output += "..."
      m.reply output
    else
      m.reply output
    end
  end

  def help(m)
    m.reply 'romanizes ur words. not 100% accurate tho'
  end

end