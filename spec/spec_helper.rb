ENV['RACK_ENV'] ||= 'development'

require_relative '../env'

Bundler.require :test

require 'minitest/autorun'
require 'minitest/spec'

class MiniTest::Spec
  include Rack::Test::Methods
  
  def run(*args, &block)
    Sequel::Model.db.transaction(rollback: :always) {super}
  end
end





