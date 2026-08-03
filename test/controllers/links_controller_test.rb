require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  test "index lists every link, newest first" do
    get root_path

    assert_response :success
    assert_select "tbody tr:first-child a.slug", text: "/guides"
    assert_select "tbody tr:last-child a.slug", text: "/rails"
  end

  test "creates a link with a generated slug" do
    assert_difference -> { Link.count }, 1 do
      post links_path, params: { link: { url: "https://example.com/deep/page" } }
    end

    assert_redirected_to root_path
  end

  test "creates a link with a custom slug" do
    post links_path, params: { link: { url: "https://example.com", slug: "docs" } }

    assert_equal "https://example.com", Link.find_by!(slug: "docs").url
  end

  test "refuses a destination that is not a URL" do
    assert_no_difference -> { Link.count } do
      post links_path, params: { link: { url: "not-a-url" } }
    end

    assert_response :unprocessable_content
    assert_select ".errors li", text: "Url must start with http:// or https://"
  end

  test "refuses a slug that is already taken" do
    assert_no_difference -> { Link.count } do
      post links_path, params: { link: { url: "https://example.com", slug: "rails" } }
    end

    assert_select ".errors li", text: "Slug has already been taken"
  end

  test "show reports the visit statistics" do
    get link_path(links(:rails))

    assert_response :success
    assert_select ".stats dd", text: "3"
    assert_select ".referrers .source", text: "https://news.ycombinator.com/"
  end

  test "destroys a link" do
    assert_difference -> { Link.count }, -1 do
      delete link_path(links(:guides))
    end

    assert_redirected_to root_path
  end
end
