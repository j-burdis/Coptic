require "test_helper"

class IndianCollection::PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get indian_collection_pages_index_url
    assert_response :success
  end
end
