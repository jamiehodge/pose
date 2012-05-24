require './env'

map '/assets' do
  run Assets
end

map '/proxies' do
  run Proxies
end
