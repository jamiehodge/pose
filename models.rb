class Asset < Sequel::Model  
  one_to_many :proxies
  
  def dir
    File.join 'repo', id.to_s
  end
  
end

class Proxy < Sequel::Model
  many_to_one :asset
  
  def dir
    File.join 'repo', asset_id.to_s
  end
  
end

module Storable
  
  attr_reader :tempfile
  
  def tempfile=(t)
    modified!
    @tempfile = t
  end
  
  def path
    File.join dir, filename
  end
  
  def complete?
    File.file?(path) && File.size(path) == size
  end
  
  def before_save
    self.size ||= tempfile.size if tempfile
    super
  end
  
  def after_save
    super
    FileUtils.mkdir_p dir
    append(tempfile) if tempfile
  end
  
  def before_destroy
    FileUtils.rm_rf dir
    super
  end
  
  def append(data)
    data.rewind
    File.open path, 'a' do |f|
      while blk = data.read(65536) do
        f << blk
      end
    end
  end
end

Asset.include Storable
Proxy.include Storable