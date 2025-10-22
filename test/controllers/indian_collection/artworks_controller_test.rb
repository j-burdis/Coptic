require "test_helper"

class IndianCollection::ArtworksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get indian_collection_artworks_index_url
    assert_response :success
  end

  test "should get show" do
    get indian_collection_artworks_show_url
    assert_response :success
  end
end
