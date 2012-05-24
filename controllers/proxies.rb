class Proxies < Base
  
  post '/' do
    @proxy = Proxy.new
    @proxy.set_fields params[:file].merge(asset_id: params[:asset_id]), [:asset_id, :filename, :type, :size, :tempfile]
    @proxy.save
    
    headers \
      'Location' => url("/#{@proxy.id}")
    
    @proxy.to_json root: true
  end
  
  get '/:id' do
    proxy = Proxy[ params[:proxy_id] ] || not_found
    send_file proxy.path, type: proxy.type
  end
  
end