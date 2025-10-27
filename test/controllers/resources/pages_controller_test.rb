require "test_helper"

class Resources::PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resources_pages_index_url
    assert_response :success
  end
end
