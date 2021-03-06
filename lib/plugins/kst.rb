module Cinch
  module Plugins
    class Kst
      include Cinch::Plugin

      match /(kst)$/
      match /(help kst)$/, method: :help

      def execute(m)
        utc = Time.now.utc
        kst = utc + (9 * 3600)
        time = kst.strftime("%F %H:%M KST")
        m.reply time
      end

      def help(m)
        m.reply 'returns date and time (KST)'
      end

    end
  end
end
