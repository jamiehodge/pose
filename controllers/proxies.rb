class Proxies < Sinatra::Base
  
  get '/:id' do
    proxy = Proxy[ params[:id] ] || not_found
    send_file proxy.path, type: proxy.type
  end
end