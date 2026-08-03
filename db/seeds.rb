# A few links with a plausible visit history, so the interface has something to
# show in development. Safe to run more than once.

SAMPLES = {
  "routing"  => "https://guides.rubyonrails.org/routing.html",
  "doctrine" => "https://rubyonrails.org/doctrine",
  "omakase"  => "https://dhh.dk/2012/rails-is-omakase.html"
}

REFERRERS = [ nil, "https://news.ycombinator.com/", "https://lobste.rs/", "https://ruby.social/" ]

SAMPLES.each do |slug, url|
  link = Link.find_or_create_by!(slug: slug) { |candidate| candidate.url = url }

  next if link.visits.any?

  rand(20..120).times do
    link.visits.create! created_at: rand(14.days).seconds.ago, referrer: REFERRERS.sample
  end
end

puts "Seeded #{Link.count} links and #{Visit.count} visits."
