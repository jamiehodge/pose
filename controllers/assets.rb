require 'stringio'
require 'net/http'

class Assets < Base
  
  disable :protection
  
  get '/' do
    Asset.to_json naked: true
  end
  
  post '/' do
    @asset = Asset.new
    @asset.set_fields params[:file], [:filename, :type, :size, :tempfile]
    @asset.save
    
    headers \
      'Location' => url("/#{@asset.id}")
      
    request_proxy if @asset.complete?
      
    @asset.to_json naked: true, include: { size: {}, proxies: { naked: true } }
  end
  
  before %r{^/(?<id>\d+)} do
    @asset = Asset[ params[:id] ] || not_found
  end
  
  get '/:id/media' do
    send_file @asset.path, type: @asset.type
  end
  
  get '/:id' do
    @asset.to_json naked: true, include: { size: {}, proxies: { naked: true, except: :asset_id } }
  end
  
  patch '/:id' do
    @asset.set_fields params[:file], [:tempfile]
    @asset.save

    request_proxy if @asset.complete?
    
    @asset.to_json naked: true, include: { size: {}, proxies: { naked: true } }
  end
  
  delete '/:id' do
    @asset.destroy
    201
  end
  
  def request_proxy
    uri = URI 'http://localhost:9292'
    res = Net::HTTP.post_form uri, 
      source: url("/#{@asset.id}/media"), 
      destination: url("/proxies", true, false), 
      format: 'webm',
      asset_id: @asset.id
  end
end