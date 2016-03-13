require 'wolfram-alpha'

module Cinch
  module Plugins
    class Wa
      include Cinch::Plugin

      match /(wa) (.+)/
      match /(help wa)$/, method: :help

      def execute(m, prefix, wa, text)
        input_array = text.split(/[[:space:]]/)
        query = input_array.join(' ').downcase
        options = { "format" => "plaintext" }
        client = WolframAlpha::Client.new "#{ENV['WA_ID']}", options
        response = client.query(query)
        return m.reply "bad query bru" if response["Input"].nil?
        input = response["Input"]
        result = response.find { |pod| pod.title == "Result" }
        interp = input.subpods[0].plaintext
        interp.delete!("\n")
        answer = result.subpods[0].plaintext
        answer.delete!("\n")
        if answer.size > 200
          answer.slice! 200..-1
          answer += "..."
        end
        m.reply "#{interp} => #{answer}"
      end

      def help(m)
        m.reply 'Sends a query to wolfram alpha and returns a result'
      end

    end
  end
end
