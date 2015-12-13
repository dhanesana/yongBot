module Cinch
  module Plugins
    class ThisOrThat
      include Cinch::Plugin

      match /(.+) (OR) (.+)$/
      match /(help)\s(this)\s(OR)\s(that)/, method: :help

      def execute(m, prefix, this, orr, that)
        decision = rand(0..1) == 0 ? this : that
        m.reply rand(0..1) < 1 ? "hm.. #{decision}" : "#{decision}!"
      end

      def help(m)
        m.reply "helps you make an otherwise difficult decision"
      end

    end
  end
end
