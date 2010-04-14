require File.expand_path( File.dirname(__FILE__) + '/test_helper')

require 'psm'

class PrintStuffMailTest < Test::Unit::TestCase
  
  context "PrintStuffMail" do
    
    setup do
      Artifice.activate_with(FakePSM)
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
      
      should "allow to set an account_id" do
        assert_respond_to PSM, :account_id
        assert_respond_to PSM, :account_id=
      end
      
      should "raise a SecurityError unless @account_id isn't set" do
        assert_raise(SecurityError) { PSM.mail!(@message, @address) {} }
      end

      context "with a set account_id" do
        
        setup do
          PSM.account_id = 'john_smith'
        end
        
        should "raise a SecurityError unless a 'confirm block' is passed (it's a really dangerous method)" do
          assert_raise(SecurityError) { PSM.mail!(@message, @address) {} }
          assert_nothing_raised { PSM.mail!(@message, @address) {|c| c.confirm! } }
        end
        
        should "raise an ArgumentError unless @message and @address are specified" do
          assert_raise(ArgumentError) { PSM.mail! }
          assert_raise(ArgumentError) { PSM.mail!(@message) }
          assert_nothing_raised { PSM.mail!(@message, @address, &:confirm!) }
        end

        should "accept an optional @return_address" do
          assert_nothing_raised do
            PSM.mail!(@message, @address, @return_address, &:confirm!)
          end
        end

      end
      
    end
  
    context "as a module to be #include-d" do
      
      setup do
        class Tempfile; include PSM end
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
        assert !defined? @tempfile.address
        assert_raise(NoMethodError) { @tempfile.mail!(@message) }
      end
      
    end
    
    context "when accessing the webservice" do
      
      should "post letters" do
        letter = PSM.mail!(@message, @address, @return_address, &:confirm!)
        assert_equal 'processing', letter.state
      end
      
      should "be able to update a letter's status" do
        
      end
      
    end
    
    teardown do
      Artifice.deactivate
    end
    
  end
  
  
end