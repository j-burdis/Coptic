require "test_helper"

class ResourcesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resources_index_url
    assert_response :success
  end

  test "should get show" do
    get resources_show_url
    assert_response :success
  end

  test "should get films_and_audio" do
    get resources_films_and_audio_url
    assert_response :success
  end

  test "should get texts" do
    get resources_texts_url
    assert_response :success
  end

  test "should get publications" do
    get resources_publications_url
    assert_response :success
  end

  test "should get chronology" do
    get resources_chronology_url
    assert_response :success
  end
end
