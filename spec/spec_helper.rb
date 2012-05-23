ENV['RACK_ENV'] = 'test'

require_relative '../env'

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

class MiniTest::Spec
  include Rack::Test::Methods
  
  def run(*args, &block)
    Sequel::Model.db.transaction(rollback: :always) {super}
  end
end





