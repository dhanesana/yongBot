require 'open-uri'
require 'aws-sdk'

module Cinch
  module Plugins
    class Celeb
      include Cinch::Plugin

      match /(celeb) (.+)/
      match /(help celeb)$/, method: :help

      def initialize(*args)
        super
        Aws.config.update({
          region: 'us-west-2',
          credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
        })
        @client = Aws::Rekognition::Client.new
      end

      def execute(m, prefix, celeb, link)
        img_url = URI.encode(link)
        begin
          resp = @client.recognize_celebrities(
            image: { bytes: open(img_url).read }
          )
        rescue Exception => e
          return m.reply "Error: #{e}"
        end
        return m.reply "that don't look like any celeb i kno" if resp.celebrity_faces.size < 1
        celeb_name = resp.celebrity_faces[0].name
        celeb_conf = resp.celebrity_faces[0].match_confidence.round(2)
        m.reply "#{m.user.nick}: that looks like #{celeb_name}. #{celeb_conf}% sure.."
      end

      def help(m)
        m.reply 'returns a celebrity that resembles/matches a face in specified image'
      end

    end
  end
end
