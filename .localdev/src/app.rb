ENV['BUNDLE_GEMFILE'] = '/var/task/Gemfile'
require 'bundler/setup'
require 'net/http'
require 'socksify/http'
require 'json'
require 'uri'

def handler(event:, context:)
  context_data = context.instance_variables.each_with_object({}) { |ivar, memo| memo[ivar.to_s.sub('@','')] = context.instance_variable_get(ivar) }
  payload = { event: event, context: context_data }.to_json
  uri = URI.parse("http://#{ENV['TS_REMOTE_PROXY_HOST']}:#{ENV['TS_REMOTE_PROXY_PORT']}/")
  response_body = Net::HTTP.socks_proxy('localhost', 1055).start(uri.host, uri.port) do |http|
    request = Net::HTTP::Post.new(uri.request_uri, 
      'Content-Type' => 'application/json',
      'Content-Length' => payload.length.to_s)
    request.body = payload
    response = http.request(request)
    puts "RESPONSE: #{response}"
    response.body
  end
  JSON.parse(response_body)
end
