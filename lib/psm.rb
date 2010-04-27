require 'net/http'
require 'base64'
require 'json'

require 'addressable/uri'
require 'psm/session'

module PrintStuffMail

  BASE_URL = "s.copypastel.com"

  class Confirmation
    def initialize; @confirmed = false end
    def confirm!;   @confirmed = true end
    def confirmed?; @confirmed end
  end

  class << self
    attr_accessor :account_id
    
    def mail!( message, address, return_address = nil )
      raise(SecurityError, 'no account_id set.') unless account_id
      yield c = Confirmation.new
      raise(SecurityError, 'need to confirm!') unless c.confirmed?
      
      @session ||= Session.new account_id
      raise unless @session.active? or @session.renew! # needs an error type
      Letter.new post_letter(message, address, return_address)
    end
    
    private
    
    def get_session(account_id)
      @session = Session.new(account_id)
    end

    def post_letter(message, address, return_address = nil)
      uri = Addressable::URI.new  :host => PSM::BASE_URL,
                                  :path => '/letters'
      params = { :message => message, :address => address, 
                 :return_address => return_address,
                 :session => @session.id }
      params.delete_if {|k, v| v.nil?}
      uri.query_values = params
      response = Net::HTTP.start(PSM::BASE_URL, 80) do |http|
        http.post("/psm/letters/print", uri.query)
      end
      JSON.parse response.body
    end
    
  end
  
  def mail!( message, return_address = nil, &block )
    PSM.mail!( message, self.address, return_address, block)
  end
  
  private

  def encrypt(params)
    @encrypter ||= OpenSSL::PKey::RSA.new SECRET_KEY
    decrypter.public_encrypt params.to_json
    @psm_encrypter.public_encrypt params[:payload]
  end
  
  def decrypt(params)
    if payload = params.delete(:payload)
      escaped = CGI.unescape(payload)
      add_params = JSON.parse @psm_decrypter.private_decrypt(escaped)
      params.merge add_params
    end
    params
  end

end

# Short acronym for quick reference
PSM = PrintStuffMail
