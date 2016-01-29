module Cinch
  module Plugins
    class Iono
      include Cinch::Plugin

      match /(iono)$/
      match /(help iono)$/, method: :help

      def execute(m)
        yes = ['yes', 'yeah', 'yeee', 'ya', 'YES!'].sample
        no = ['no', 'nah', 'nope', 'nooo', 'NO!'].sample
        m.reply rand(0..1) == 0 ? yes : no
      end

      def help(m)
        m.reply "returns yes || no"
      end

    end
  end
end
