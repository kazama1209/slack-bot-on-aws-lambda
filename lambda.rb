require 'json'
require 'rack'
require 'base64'

$app ||= Rack::Builder.parse_file("#{__dir__}/config.ru").first
ENV['RACK_ENV'] ||= 'production'

def handler(event:, context:)
  body = if event['isBase64Encoded']
    Base64.decode64 event['body']
  else
    event['body']
  end || ''

  headers = event.fetch 'headers', {}

  env = {
    'REQUEST_METHOD' => event.fetch('httpMethod'),
    'SCRIPT_NAME' => '',
    'PATH_INFO' => event.fetch('path', ''),
    'QUERY_STRING' => Rack::Utils.build_query(event['queryStringParameters'] || {}),
    'SERVER_NAME' => headers.fetch('Host', 'localhost'),
    'SERVER_PORT' => headers.fetch('X-Forwarded-Port', 443).to_s,

    'rack.version' => Rack::VERSION,
    'rack.url_scheme' => headers.fetch('CloudFront-Forwarded-Proto') { headers.fetch('X-Forwarded-Proto', 'https') },
    'rack.input' => StringIO.new(body),
    'rack.errors' => $stderr,
  }

  headers.each_pair do |key, value|
    name = key.upcase.gsub '-', '_'
    header = case name
      when 'CONTENT_TYPE', 'CONTENT_LENGTH'
        name
      else
        "HTTP_#{name}"
    end
    env[header] = value.to_s
  end

  begin
    status, headers, body = $app.call env

    body_content = ""
    body.each do |item|
      body_content += item.to_s
    end

    response = {
      'statusCode' => status,
      'headers' => headers,
      'body' => body_content
    }
    if event['requestContext'].has_key?('elb')
      response['isBase64Encoded'] = false
    end
  rescue Exception => exception
    response = {
      'statusCode' => 500,
      'body' => exception.message
    }
  end

  response
end
