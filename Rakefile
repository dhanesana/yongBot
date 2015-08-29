require 'dotenv-heroku/tasks'
require 'heroku-api'

task :scale_down do
  heroku = Heroku::API.new(api_key: "#{ENV['HEROKU_API']}")
  heroku.post_ps_scale("#{ENV['APP_NAME']}", 'bot', 0)
end

task :scale_up do
  heroku = Heroku::API.new(api_key: "#{ENV['HEROKU_API']}")
  heroku.post_ps_scale("#{ENV['APP_NAME']}", 'bot', 1)
end
