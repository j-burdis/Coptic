require "test_helper"

class Resources::CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resources_collections_index_url
    assert_response :success
  end

  test "should get show" do
    get resources_collections_show_url
    assert_response :success
  end
end
