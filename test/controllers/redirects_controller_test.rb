require "test_helper"

class RedirectsControllerTest < ActionDispatch::IntegrationTest
  test "sends a visitor to the destination" do
    get short_path(links(:rails).slug)

    assert_redirected_to "https://rubyonrails.org"
  end

  test "redirects temporarily so that visits keep being counted" do
    get short_path(links(:rails).slug)

    assert_response :found
  end

  test "records the visit and its referrer" do
    link = links(:guides)

    assert_difference -> { link.visits.count }, 1 do
      get short_path(link.slug), headers: { "HTTP_REFERER" => "https://example.com/post" }
    end

    assert_equal "https://example.com/post", link.visits.last.referrer
    assert_equal 1, link.reload.visits_count
  end

  test "records a direct visit with no referrer" do
    get short_path(links(:guides).slug)

    assert_nil links(:guides).visits.last.referrer
  end

  test "an unknown slug is not found" do
    get "/no-such-link"

    assert_response :not_found
  end
end
