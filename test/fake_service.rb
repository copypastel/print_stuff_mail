require 'sinatra/base'
require 'json'

class Letter < Struct(:message, :address, :return_address); end

class Helpers
  
  @@encrypter = OpenSSL::PKey::RSA.new '12345'
  @@decrypter = OpenSSL::PKey::RSA.new 'abcde'
  
  def encrypt(payload)
    CGI.escape @@encrypter.private_encrypt(params.to_json)
  end
  
  def decrypt(payload)
    JSON.parse @@encrypter.public_decrypt(CGI.unescape(payload))
  end
  
end

class Sessions < Sinatra::Base
  
  # may be extend
  include Helpers
  
  post '/letter/print' do
    halt 400 unless params[:message] and params[:address]
    @letter = Letter.new(params[:message], params[:address], params[:return_address])
    { :status => 201, 
      :id => 1,
      :message => @letter.message,
      :address => @letter.address,
      :return_address => @letter.return_address,
      :state => :processing }.to_json
  end
  
  get '/letter/:id' do
    halt 404 if @letter.nil? or params[:id].to_i != 1
    { :status => 200,
      :id => 1,
      :message => @letter.message,
      :address => @letter.address,
      :return_address @letter.return_address,
      :state => :processing }.to_json
  end
  
end
