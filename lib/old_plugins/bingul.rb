module Cinch
  module Plugins
    class Bingul
      include Cinch::Plugin

      match /(bingul)$/
      match /(help bingul)$/, method: :help

      def execute(m)
        m.reply "http://www.youtube.com/watch?v=ZQMn_LWz32E"
      end

      def help(m)
        m.reply "sry arrgh .."
      end

    end
  end
end
