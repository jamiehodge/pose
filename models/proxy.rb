class Proxy < Sequel::Model
  include Storable
  
  many_to_one :asset
  
  def dir
    File.join ENV['REPOSE_REPO'], asset_id.to_s
  end
  
end