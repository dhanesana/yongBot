module Cinch
  module Plugins
    class Iono
      include Cinch::Plugin

      match /(iono)$/, prefix: /^(\.)/
      match /(help iono)$/, method: :help, prefix: /^(\.)/

      def execute(m)
        yes = ['yes', 'yeah', 'yeee', 'ya', 'ye'].sample
        no = ['no', 'nah', 'nope', 'nooo', 'nein bro'].sample
        m.reply rand(0..1) == 0 ? yes : no
      end

      def help(m)
        m.reply "returns yes || no"
      end

    end
  end
end
