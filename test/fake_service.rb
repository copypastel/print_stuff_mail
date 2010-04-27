require 'sinatra/base'
require 'openssl'
require 'json'

class Letter < Struct.new(:message, :address, :return_address); end

module Helpers
  
  @@encrypter = OpenSSL::PKey::RSA.new
  @@decrypter = OpenSSL::PKey::RSA.new
  
  def encrypt(payload)
    CGI.escape @@encrypter.private_encrypt(params.to_json)
  end
  
  def decrypt(payload)
    JSON.parse @@encrypter.public_decrypt(CGI.unescape(payload))
  end
  
end

class FakePSM < Sinatra::Base
  
  # may be extend
  include Helpers
  
  post '/psm/sessions' do
    halt 400 unless params[:account_id] == 'john_smith'
    { :status => 201,
      :id => 'abcde',
      :expires => Time.now + 60*30
      }.to_json
  end
  
  post '/psm/letters/print' do
    halt 400 unless params[:message] and params[:address] and params[:session] == 'abcde'
    @letter = Letter.new(params[:message], params[:address], params[:return_address])
    { :status => 201, 
      :id => 1,
      :message => @letter.message,
      :address => @letter.address,
      :return_address => @letter.return_address,
      :state => :processing }.to_json
  end
  
  get '/psm/letters/:id' do
    halt 400 unless params[:token] == 'abcde'
    halt 404 if @letter.nil? or params[:id].to_i != 1
    { :status => 200,
      :id => 1,
      :message => @letter.message,
      :address => @letter.address,
      :return_address => @letter.return_address,
      :state => :processing }.to_json
  end
  
end
