require "test_helper"

class ApiControllerTest < ActionDispatch::IntegrationTest
  class ArticlesControllerTest < ActionDispatch::IntegrationTest
    test "should get ping" do
      get ping_url
      assert_response :success
    end
    test "should get posts" do
      get posts_url
      assert_response :success
    end
  end
end
