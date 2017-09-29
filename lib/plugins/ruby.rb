module Cinch
  module Plugins
    class RubyVersion
      include Cinch::Plugin

      match /(ruby)$/
      match /(help ruby)$/, method: :help

      def execute(m)
        m.reply "ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE} revision #{RUBY_REVISION}) [#{RUBY_PLATFORM}]"
      end

      def help(m)
        m.reply "returns ruby version, patch level, release date, revision, and platform"
      end

    end
  end
end
