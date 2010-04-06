require File.expand_path( File.dirname(__FILE__) + '/../test_helper')

require 'psm/session'

class SessionTest < Test::Unit::TestCase
  
  include PrintStuffMail
  
  context "A Session" do
    
    should "raise an exception if it can't get a token when initializing" do
      assert_raise(RuntimeError) { Session.new 'not_a_valid_account_id' }
    end
    
    setup do
      Artifice.activate_with(FakePSM)
      @session = Session.new 'john_smith'
    end
    
    context "after being initialized" do
      
      should "measure how long it has left before it needs to renew" do
        assert @session.time_left > @session.time_left
      end
      
      should "be able to tell if its current token has expired" do
        assert !@session.expired?
      end
      
      should "have syntaxtic sugar to check if it's token is still valid" do
        assert @session.valid?
      end
      
      should "be able to renew itself" do
        old_expiration = @session.expiration
        sleep 1
        assert @session.renew!
        assert @session.expiration > old_expiration
      end
      
    end
  end
end