require "test_helper"

class IndianCollection::ResourcesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get indian_collection_resources_index_url
    assert_response :success
  end

  test "should get show" do
    get indian_collection_resources_show_url
    assert_response :success
  end
end
