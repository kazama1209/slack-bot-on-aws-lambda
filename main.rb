require 'dotenv'
require 'slack-ruby-client'
require 'sinatra'
require './src/weather'

Dotenv.load

Slack.configure do |conf|
  conf.token = ENV['SLACK_BOT_TOKEN']
end

get '/' do
  'This is SlackBot on AWS Lambda'
end

post '/webhook' do
  client = Slack::Web::Client.new

  channel_id = params['channel_id']
  command = params['command']

  case command
    when '/nerima'
      weather = Weather.new
      client.chat_postMessage channel: channel_id, text: weather.current_temp('Nerima'), as_user: true
  end

  return
end
