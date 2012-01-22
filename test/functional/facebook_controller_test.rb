require 'test_helper'

class FacebookControllerTest < ActionController::TestCase
  test "should get callback" do
    get :callback
    assert_response :success
  end

  test "should get permission" do
    get :permission
    assert_response :success
  end

end
