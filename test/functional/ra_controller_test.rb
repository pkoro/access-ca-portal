require File.dirname(__FILE__) + '/../test_helper'
require 'ra_controller'

# Re-raise errors caught by the controller.
class RaController; def rescue_action(e) raise e end; end

class RaControllerTest < Test::Unit::TestCase
  def setup
    @controller = RaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
