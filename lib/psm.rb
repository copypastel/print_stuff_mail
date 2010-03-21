module PrintStuffMail

  class Confirmation
    def initialize; @confirmed = false end
    def confirm!;   @confirmed = true end
    def confirmed?; @confirmed end
  end

  class << self
    def mail!( message, address, return_address = nil )
      raise(SecurityError, 'need to confirm!') unless block_given?
      yield c = Confirmation.new
      raise(SecurityError, 'need to confirm!') unless c.confirmed?
    end
  end
  
  def mail!( message, return_address = nil, &block )
    PSM.mail!( message, self.address, return_address, block)
  end

end

# Short acronym for quick reference
PSM = PrintStuffMail
