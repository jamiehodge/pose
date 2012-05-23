require 'bundler/setup'
require 'stalker'
require 'sequel'
require 'sqlite3'
require 'tempfile'

require_relative 'env'

include Stalker

job 'asset.image.thumb' do |args|
  transcode(
    "-s 80x80",
    args['input'],
    'image/png',
    args['id']
  )
end

def transcode(args, input, type, asset_id)
  output = Tempfile.new(['proxy', ".#{type.split('/').last}"])
  
  `ffmpeg -y -i "#{input}" #{args} "#{output.path}"`
  
  if success?
    proxy = Proxy.create(
      asset_id: asset_id,
      filename: File.basename(output),
      type: type,
      size: output.size
    )
    proxy.append output
  end
end

def success?
  $?.to_i == 0
end