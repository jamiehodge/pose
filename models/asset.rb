class Asset < Sequel::Model
  include Storable
   
  one_to_many :proxies
  
  def dir
    File.join ENV['REPOSE_REPO'], id.to_s
  end
  
end
