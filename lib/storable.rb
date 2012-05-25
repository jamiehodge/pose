module Storable
  
  attr_reader :tempfile
  
  def tempfile=(t)
    modified!
    @tempfile = t
  end
  
  def path
    File.join dir, filename
  end
  
  def file_size
    File.file?(path) ? File.size(path) : 0
  end
  
  def complete?
    file_size == size
  end
  
  def before_validation
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
  
  def validate
    super
    errors.add(:tempfile, 'invalid patch') if tempfile && (complete? || tempfile.size + file_size > size)
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