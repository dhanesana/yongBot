module Cinch
  module Plugins
    class Iono
      include Cinch::Plugin

      match /(iono)$/
      match /(help iono)$/, method: :help

      def execute(m)
        yes_text = ['yes', 'yeah', 'yeee', 'ya', 'YES!'].sample
        no_text  = ['no', 'nah', 'nope', 'nooo', 'NO!'].sample
        m.reply rand(0..1) == 0 ? "#{yes_text}" : "#{no_text}"
      end

      def help(m)
        m.reply "returns yes || no"
      end

    end
  end
end
