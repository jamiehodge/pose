class Base < Sinatra::Base

  use Rack::Parser, content_types: {
    'application/octet-stream' => Proc.new { |body| { file: { tempfile: StringIO.new(body) } } }
  }
  use Rack::MethodOverride
  
  options '/' do
    200
  end
  
  before do
    content_type :json
    headers \
      'Access-Control-Allow-Origin'  => '*',
      'Access-Control-Allow-Methods' => %w{GET POST PUT DELETE}.join(','),
      'Access-Control-Allow-Headers' => %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(",")
  end
  
  error Sequel::ValidationFailed, Sequel::HookFailed do
    400
  end
end
