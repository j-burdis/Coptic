require "test_helper"

class Gallery::ArtworksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gallery_artworks_index_url
    assert_response :success
  end

  test "should get paintings" do
    get gallery_artworks_paintings_url
    assert_response :success
  end

  test "should get prints" do
    get gallery_artworks_prints_url
    assert_response :success
  end

  test "should get design" do
    get gallery_artworks_design_url
    assert_response :success
  end

  test "should get indian_leaves" do
    get gallery_artworks_indian_leaves_url
    assert_response :success
  end

  test "should get indian_waves" do
    get gallery_artworks_indian_waves_url
    assert_response :success
  end

  test "should get quantel_paintbox" do
    get gallery_artworks_quantel_paintbox_url
    assert_response :success
  end

  test "should get memories_of_bombay_mumbai" do
    get gallery_artworks_memories_of_bombay_mumbai_url
    assert_response :success
  end

  test "should get other" do
    get gallery_artworks_other_url
    assert_response :success
  end

  test "should get missing_works" do
    get gallery_artworks_missing_works_url
    assert_response :success
  end

  test "should get destroyed" do
    get gallery_artworks_destroyed_url
    assert_response :success
  end

  test "should get all" do
    get gallery_artworks_all_url
    assert_response :success
  end
end
