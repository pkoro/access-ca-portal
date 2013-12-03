require File.dirname(__FILE__) + '/../test_helper'
require 'cert_controller'

# Re-raise errors caught by the controller.
class CertController; def rescue_action(e) raise e end; end

class CertControllerTest < Test::Unit::TestCase
  def setup
    @controller = CertController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
