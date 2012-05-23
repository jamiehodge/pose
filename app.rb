require 'stringio'

class App < Sinatra::Base
  
  use Rack::Parser, content_types: {
    'application/octet-stream' => Proc.new { |body| { file: { tempfile: StringIO.new(body) } } }
  }
  use Rack::MethodOverride
  
  get '/' do
    Asset.to_json root: true
  end
  
  post '/' do
    @asset = Asset.new
    @asset.set_fields params[:file], [:filename, :type, :size, :tempfile]
    @asset.save
    
    headers \
      'Location' => url("/#{@asset.id}")
      
    @asset.to_json root: true, include: { size: {}, proxies: { naked: true } }
  end
  
  before %r{^/(?<id>\d+)} do
    @asset = Asset[ params[:id] ] || not_found
  end
  
  get '/:id' do
    @asset.to_json root: true, include: { size: {}, proxies: { naked: true, except: :asset_id } }
  end
  
  patch '/:id' do
    @asset.set_fields params[:file], [:tempfile]
    @asset.save
    
    # Stalker.enqueue('asset.image.thumb', id: @asset.id, input: @asset.path) if @asset.complete?
    
    @asset.to_json root: true, include: { size: {}, proxies: { naked: true } }
  end
  
  delete '/:id' do
    @asset.destroy
    201
  end
  
  error Sequel::ValidationFailed, Sequel::HookFailed do
    400
  end
  
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
end