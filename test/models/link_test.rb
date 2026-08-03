require "test_helper"

class LinkTest < ActiveSupport::TestCase
  test "generates a slug when none is given" do
    link = Link.create! url: "https://example.com"

    assert_match(/\A[a-zA-Z0-9_-]{#{Link::SLUG_LENGTH}}\z/, link.slug)
  end

  test "keeps a custom slug, trimmed" do
    assert_equal "docs", Link.create!(url: "https://example.com", slug: " docs ").slug
  end

  test "treats a blank custom slug as no slug at all" do
    assert_predicate Link.create!(url: "https://example.com", slug: "  ").slug, :present?
  end

  test "requires the slug to be unique" do
    link = Link.new url: "https://example.com", slug: "rails"

    assert_not link.valid?
    assert_includes link.errors[:slug], "has already been taken"
  end

  test "refuses slugs that would not survive a URL" do
    assert_not Link.new(url: "https://example.com", slug: "hello world").valid?
    assert_not Link.new(url: "https://example.com", slug: "a/b").valid?
  end

  test "requires an http destination" do
    link = Link.new url: "example.com"

    assert_not link.valid?
    assert_includes link.errors.full_messages, "Url must start with http:// or https://"
  end

  test "strips surrounding whitespace from the destination" do
    assert_equal "https://example.com", Link.create!(url: "  https://example.com  ").url
  end

  test "counts visits per day, quiet days included" do
    link = Link.create! url: "https://example.com"
    link.visits.create! created_at: Date.new(2026, 7, 20).noon
    link.visits.create! created_at: Date.new(2026, 7, 20).noon
    link.visits.create! created_at: Date.new(2026, 7, 22).noon

    per_day = link.visits_per_day days: 4, through: Date.new(2026, 7, 22)

    assert_equal Date.new(2026, 7, 19), per_day.keys.first
    assert_equal [ 0, 2, 0, 1 ], per_day.values
  end

  test "ranks referrers by popularity and ignores direct visits" do
    assert_equal({ "https://news.ycombinator.com/" => 2 }, links(:rails).top_referrers)
  end

  test "reports when it was last visited" do
    assert_nil links(:guides).last_visited_at
    assert_equal visits(:direct).created_at, links(:rails).last_visited_at
  end

  test "deleting a link takes its visit history with it" do
    assert_difference -> { Visit.count }, -3 do
      links(:rails).destroy
    end
  end
end
