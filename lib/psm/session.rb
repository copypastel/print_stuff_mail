require 'net/http'
require 'date'
require 'json'

module PrintStuffMail
  class Session
    
    attr_reader :id, :last_response, :expiration
    
    def initialize(account_id)      
      @account_id = account_id
      raise "(PSM::Session) couldn't get a session token." unless renew! # We don't want to instantiate unless we can get a session
    end
    
    def time_left
      @expiration - DateTime.now # returns Rational. Wonder which units...
    end
    
    def renew!
      @last_response = get_response
      return false unless @last_response['status'] == 201 # We don't have to error out if we can't renew
      @expiration = DateTime.parse(@last_response['expires'])
      @id = @last_response['id']
      true
    end
    
    def expired?
      (@expiration - DateTime.now) < 0
    end
    
    def active?
      not expired?
    end
    
    alias_method :valid?, :active?
    
    private
    
    def get_response
      query = "account_id=#{@account_id}"
      begin
        response = Net::HTTP.start(PSM::BASE_URL,80) do |http|
          http.post("/psm/sessions", query)
        end
        JSON.parse(response.body)
      rescue
        {}
      end
    end
    
  end
end
