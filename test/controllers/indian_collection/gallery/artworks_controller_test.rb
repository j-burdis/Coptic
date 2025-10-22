require "test_helper"

class IndianCollection::Gallery::ArtworksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get indian_collection_gallery_artworks_index_url
    assert_response :success
  end

  test "should get portrait" do
    get indian_collection_gallery_artworks_portrait_url
    assert_response :success
  end

  test "should get elephants" do
    get indian_collection_gallery_artworks_elephants_url
    assert_response :success
  end

  test "should get flora_fauna" do
    get indian_collection_gallery_artworks_flora_fauna_url
    assert_response :success
  end
end
