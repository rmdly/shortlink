class Link < ApplicationRecord
  SLUG_LENGTH = 7

  # Left unanchored so that config/routes.rb can constrain a path segment with
  # it. Anchored at the point of validation below.
  SLUG_PATTERN = /[a-zA-Z0-9_-]{1,32}/

  has_many :visits, dependent: :delete_all

  normalizes :url,  with: ->(url)  { url.strip }
  normalizes :slug, with: ->(slug) { slug.strip.presence }

  before_validation :assign_slug, on: :create

  validates :url, presence: true,
    format: { with: %r{\Ahttps?://\S+\z}, message: "must start with http:// or https://", allow_blank: true }
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A#{SLUG_PATTERN}\z/, message: "may only contain letters, numbers, dashes and underscores", allow_blank: true }

  scope :newest_first, -> { order(created_at: :desc) }

  # Counts every day in the window, including the quiet ones, so a caller can
  # chart the range without filling in the gaps itself.
  def visits_per_day(days: 14, through: Date.current)
    dates = (through - days + 1)..through
    tally = visits.where(created_at: dates.first.beginning_of_day..)
                  .group("date(created_at)").count.transform_keys(&:to_date)

    dates.index_with { |date| tally[date].to_i }
  end

  def top_referrers(limit: 5)
    visits.where.not(referrer: nil).group(:referrer).order(count_all: :desc).limit(limit).count
  end

  def last_visited_at
    visits.newest_first.pick(:created_at)
  end

  private
    def assign_slug
      self.slug ||= generate_slug
    end

    def generate_slug
      loop do
        candidate = SecureRandom.base58(SLUG_LENGTH)
        break candidate unless Link.exists?(slug: candidate)
      end
    end
end
