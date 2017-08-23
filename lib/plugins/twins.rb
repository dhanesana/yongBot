require 'aws-sdk'
require 'open-uri'

module Cinch
  module Plugins
    class Twins
      include Cinch::Plugin

      match /(twins) (.+)/
      match /(help twins)$/, method: :help

      def initialize(*args)
        super
        Aws.config.update({
          region: 'us-west-2',
          credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
        })
        @client = Aws::Rekognition::Client.new
      end

      def execute(m, prefix, twins, links)
        return if $banned.include? m.user.host
        urls = links.split(/[[:space:]]/)
        source_url = URI.encode(urls[0])
        target_url = URI.encode(urls[1])
        begin
          resp = @client.compare_faces(
            source_image: { bytes: open(source_url).read },
            target_image: { bytes: open(target_url).read }
          )
        rescue Exception => e
          return m.reply "Error: #{e}"
        end
        score = resp['face_matches'].first.similarity.round(2)
        return m.reply "same person bru. #{score}% sure!" if score > 94.99
        return m.reply "#{score}% is the same person. maybe twins?" if score > 74.99
        m.reply "#{score}% is the same person"
      end

      def help(m)
        m.reply 'returns a facial similarity score for two specified images using aws rekognition'
      end

    end
  end
end
