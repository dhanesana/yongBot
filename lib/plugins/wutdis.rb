require 'open-uri'
require 'aws-sdk'

module Cinch
  module Plugins
    class Wutdis
      include Cinch::Plugin

      match /(wutdis) (.+)/
      match /(help wutdis)$/, method: :help

      def initialize(*args)
        super
        Aws.config.update({
          region: 'us-west-2',
          credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
        })
        @client = Aws::Rekognition::Client.new
      end

      def execute(m, prefix, wutdis, link)
        img_url = URI.encode(link)
        begin
          resp = @client.detect_labels(
            image: { bytes: open(img_url).read }
          )
        rescue Exception => e
          return m.reply "Error: #{e}"
        end
        return m.reply 'looks like a buncha nothing' if resp.labels.size < 1
        first_label = resp.labels.first.name
        # a or an
        resp_label = %w(a e i o u).include?(first_label[0].downcase) ? "an #{first_label}" : "a #{first_label}"
        m.reply "i see #{resp_label}. #{resp.labels.first.confidence.round(2)}% sure tho"
      end

      def help(m)
        m.reply 'identifies objects within a given image and responds with a label'
      end

    end
  end
end
