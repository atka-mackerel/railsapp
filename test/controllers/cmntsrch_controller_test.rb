require 'test_helper'

class CmntsrchControllerTest < ActionDispatch::IntegrationTest
  test "should get cmntsrch" do
    get cmntsrch_url
    assert_response :success
  end
end
