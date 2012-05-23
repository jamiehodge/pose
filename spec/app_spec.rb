require_relative 'spec_helper'

describe App do
  
  def app
    App
  end
  
  def parsed_response
    Yajl::Parser.parse last_response.body
  end
  
  let :asset do
    Fabricate.build :asset
  end
  
  let :proxy do
    Fabricate.build :proxy
  end
  
  let :file do
    Rack::Test::UploadedFile.new('spec/fixtures/bars.mov', 'video/quicktime')
  end
  
  describe 'GET /' do
    
    describe 'without assets' do
      
      it 'returns an empty array' do
        get '/'
        parsed_response.must_equal('assets' => [])
      end
      
    end
    
    describe 'with assets' do
      
      before do
        asset.save
      end
      
      it 'returns populated array' do
        get '/'
        parsed_response.must_equal(
          'assets' => [
            {"asset"=>
              {
                'id' => 1, 
                'filename' => asset.filename, 
                "type" => asset.type, 
                "size" => asset.size
              }
            }
          ]
        )
      end
    end
  end
  
  describe 'POST /' do
    
    describe 'with tempfile' do
      
      before do
        post '/', file: file
      end
      
      after do
        Asset.destroy
      end
      
      it 'creates asset' do
        Asset.count.must_equal 1
      end
      
      it 'stores media' do
        File.file? Asset.first.path
        file.size.must_equal Asset.first.size
      end
      
      it 'returns location of asset' do
        last_response.headers['Location'].must_equal 'http://example.org/1'
      end
    end
  end
  
  describe '/:id' do
    
    before do
      asset.save
    end
    
    describe 'GET /:id' do
    
      describe 'without proxies' do
      
        it 'returns asset representation' do
          get "/#{asset.id}"
          parsed_response.must_equal(
            "asset"=>
              {
                "id" => 1, 
                "filename" => asset.filename, 
                "type" => asset.type, 
                "size" => asset.size,
                "proxies" => []
              }
          )
        end
      
      end
    
      describe 'with proxies' do
      
        before do
          asset.add_proxy proxy.save
        end
      
        it 'returns asset representation' do
          get "/#{asset.id}"
          parsed_response.must_equal(
            "asset"=>
              {
                "id" => asset.id, 
                "filename" => asset.filename, 
                "type" => asset.type, 
                "size" => asset.size,
                "proxies" => [
                  "id" => proxy.id, 
                  "filename" => proxy.filename, 
                  "type" => proxy.type, 
                  "size" => proxy.size
                ]
              }
          )
        end
      end
    end
    
    describe 'PATCH /:id' do
      
      after do
        asset.destroy
      end
      
      describe 'multipart' do
        
        it 'appends media' do
          patch "/#{asset.id}", file: file
          File.size(asset.path).must_equal file.size      
        end
        
      end
    
      describe 'octet-stream' do
        
        it 'appends media' do
          patch "/#{asset.id}", file, { 'CONTENT_TYPE' => 'application/octet-stream' }
          File.size(asset.path).must_equal file.size
        end
  
      end
    end
    
    describe 'DELETE /:id' do
      
      it 'deletes asset' do
        delete "/#{asset.id}"
        Asset.count.must_equal 0
      end
    end
  end
end

