$LOAD_PATH.unshift File.expand_path( File.dirname(__FILE__) + '/../lib')

require 'shoulda'
require 'psm'

class PrintStuffMailTest < Test::Unit::TestCase
  
  context "PrintStuffMail" do
    
    context "as a singleton" do
      
      should "should define #mail! (it's a dangerous method)"
      
      should "raise unless a @message and an @address are specified"
      
      should "allow a @return_address to be specified as well"
      
    end
    
  end
  
end