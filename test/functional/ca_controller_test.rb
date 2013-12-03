require File.dirname(__FILE__) + '/../test_helper'
require 'ca_controller'

# Re-raise errors caught by the controller.
class CaController; def rescue_action(e) raise e end; end

class CaControllerTest < Test::Unit::TestCase
  def setup
    @controller = CaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
