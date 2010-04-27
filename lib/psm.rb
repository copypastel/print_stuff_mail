require 'net/http'
require 'psm/session'

# dependencies
require 'addressable/uri'
require 'json'

module PrintStuffMail

  BASE_URL = 's.copypastel.com/psm'

  class Confirmation
    def initialize; @confirmed = false end
    def confirm!;   @confirmed = true end
    def confirmed?; @confirmed end
  end

  class << self
    attr_accessor :account_id
    
    def mail!( message, address, return_address = nil )
      raise(SecurityError, 'no account_id set.') unless account_id
      raise(SecurityError, 'need to confirm!') unless block_given?
      yield c = Confirmation.new
      raise(SecurityError, 'need to confirm!') unless c.confirmed?
      
      @session ||= Session.new account_id
      raise unless @session.active? or @session.renew! # needs an error type
      post_letter(message, address, return_address)
    end
    
    private
    
    def get_session(account_id)
      @session = Session.new(account_id)
    end

    def post_letter(message, address, return_address = nil)
      uri = Addressable::URI.new  :host => PSM::BASE_URL,
                                  :path => '/letters/print'
      params = { :message => message, :address => address, 
                 :return_address => return_address,
                 :session => @session.id }
      params.delete_if {|k, v| v.nil?}
      uri.query_values = params
      response = Net::HTTP.start(PrintStuffMail::BASE_URL, 80) do |http|
        http.post(uri.path, uri.query)
      end
      JSON.parse response.body
    end
    
  end
  
  def mail!( message, return_address = nil, &block )
    PSM.mail!( message, self.address, return_address, block)
  end

end

# Short acronym for quick reference
PSM = PrintStuffMail
