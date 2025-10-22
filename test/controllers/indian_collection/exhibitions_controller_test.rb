require "test_helper"

class IndianCollection::ExhibitionsControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get indian_collection_exhibitions_list_url
    assert_response :success
  end
end
