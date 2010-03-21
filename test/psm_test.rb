$LOAD_PATH.unshift File.expand_path( File.dirname(__FILE__) + '/../lib')

require 'shoulda'
require 'psm'

class PrintStuffMailTest < Test::Unit::TestCase
  
  context "PrintStuffMail" do
    
    setup do
      @address = "Google\n1600 Amphitheatre Parkway\nMountain View, CA 94043"
      @return_address = "Apple\n1 Infinite Loop\nCupertino, CA 95014"
      @message = "Dear Eric,\nStop stealing my designs!\nLove,\nSteve"
    end
    
    should "be referenced by the shorter PSM acronym" do
      assert_equal PrintStuffMail, PSM
    end
    
    context "as a singleton" do
      
      should "define #mail! (it's a dangerous method)" do
        assert_respond_to PSM, :mail!
      end
      
      should "raise an ArgumentError unless @message and @address are specified" do
        assert_raise(ArgumentError) { PSM.mail! }
      end
      
      should "raise unless a 'confirm block' is passed (it's a really dangerous method)" do
        assert_raise(SecurityError) { PSM.mail!(@message, @address) }
        assert_nothing_raised { PSM.mail!(@message, @address) {|c| c.confirm! } }
      end
      
      should "accept an optional @return_address" do
        assert_nothing_raised do 
          PrintStuffMail.mail!(@message, @address, @return_address) {|c| c.confirm! }
        end
      end
      
    end
  
    context "as a module to be #include-d" do
      
      class Tempfile; include PSM end
      
      setup do
        @tempfile = Tempfile.new
      end
      
      should "define #mail! in the including class' instances" do
        assert_respond_to @tempfile, :mail!
      end
      
      should "raise an ArgumentError unless a @message is passed in" do
        assert_raise(ArgumentError) { @tempfile.mail! }
        assert_raise(NoMethodError) { @tempfile.mail!(@message) }
      end
      
      should "raise from within #mail! if #address isn't defined" do
        assert_raise(NoMethodError) { @tempfile.mail!(@msg) }
      end
      
    end
    
  end
  
  
end