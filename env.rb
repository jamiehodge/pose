ENV['RACK_ENV']    ||= 'development'
ENV['REPOSE_REPO'] ||= 'repo'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV'].intern

FileUtils.mkdir_p ENV['REPOSE_REPO'] 

DB = Sequel.sqlite
DB.instance_eval do
  
  unless table_exists? :assets
    create_table :assets do
      primary_key :id
      String      :filename
      String      :type
      Integer     :size
    end
  end
  
  unless table_exists? :proxies
    create_table :proxies do
      primary_key :id
      foreign_key :asset_id, :assets, on_delete: :cascade
      String      :filename
      String      :type
      Integer     :size
    end
  end
end

Sequel::Model.plugin :json_serializer

require_relative 'lib/storable'

require_relative 'models/asset'
require_relative 'models/proxy'

require_relative 'controllers/assets'
require_relative 'controllers/proxies'