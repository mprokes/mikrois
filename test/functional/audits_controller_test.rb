require 'test_helper'

class AuditsControllerTest < ActionController::TestCase
  test "should get news" do
    get :news
    assert_response :success
  end

end
