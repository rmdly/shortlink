# Shortlink

A URL shortener. Paste a long URL, get a short one, and see who followed it.

Two models, two controllers, five routes. No service objects, no JavaScript
framework, no gems beyond what `rails new` hands you. It is meant to be read
start to finish in one sitting.

## Running it

```bash
bin/setup          # installs gems, prepares the database, seeds sample data
bin/rails server
```

Then visit <http://localhost:3000>. Run `bin/rails test` for the suite,
`bin/rubocop` and `bin/brakeman` for the linters. All three should be silent.

## How it works

Five routes carry the whole application:

| Route                 | Action              | Purpose                        |
| --------------------- | ------------------- | ------------------------------ |
| `GET  /`              | `links#index`       | The shortening form and a list |
| `POST /links`         | `links#create`      | Shorten a URL                  |
| `GET  /links/:id`     | `links#show`        | Visit statistics for one link  |
| `DELETE /links/:id`   | `links#destroy`     | Forget a link                  |
| `GET  /:slug`         | `redirects#show`    | The short link itself          |

Nothing else is needed, so nothing else exists. Every controller uses only the
standard actions — there is no `POST /links/:id/visit` anywhere, because a
visit is a noun that belongs to `Visit`, not a verb bolted onto `Link`.

### The short link

`RedirectsController#show` is the hot path and the whole point:

```ruby
link = Link.find_by!(slug: params[:slug])
link.visits.create! referrer: request.referer, user_agent: request.user_agent

redirect_to link.url, allow_other_host: true
```

It answers with a 302 rather than a 301 on purpose. A permanent redirect would
be cached by the browser, and we would never hear about the visit again.

The route is declared last in `config/routes.rb` so that it only catches what
nothing else claimed, and constrained by `Link::SLUG_PATTERN` so that it never
swallows an asset path.

### Slugs

A slug is seven characters of `SecureRandom.base58` — the Bitcoin alphabet,
which drops the characters people misread aloud (`0`, `O`, `I`, `l`). That is
around 38 billion possibilities, but the model still checks for a collision
before settling on one, and a unique index on `links.slug` is the real
guarantee. Supply your own slug in the form and it is kept instead.

### Counting visits

`links.visits_count` is a plain Active Record counter cache, so the index page
lists any number of links with two queries.

`Link#visits_per_day` returns a count for **every** day in the window,
including the days nobody clicked, so the view can render a chart without
filling in the gaps itself. The chart is a `<ol>` of `<li>`s with a percentage
height — no charting library, no canvas, about a dozen lines of CSS.

## Deliberate omissions

- **No authentication.** Anyone who can reach the app can create links. That is
  fine on your laptop and *not* fine on the public internet, where an open
  shortener becomes somebody else's phishing infrastructure within days. Add
  `bin/rails generate authentication` and a `before_action :require_authentication`
  before you point a domain at this.
- **No rate limiting.** Same reasoning. `rack-attack`, or Rails' own
  `rate_limit` in the controller, is the answer when it matters.
- **No background jobs.** Recording a visit is one `INSERT` on the redirect
  path. Moving it to a queue would buy microseconds and cost a dependency.
- **No pagination.** Add it when a real list gets long enough to need it.
- **No Active Storage, Action Mailer, Action Cable or Solid Queue.** A
  shortener needs none of them, and unused framework is still framework you
  have to read past.

## Deploying

`config/deploy.yml` is the stock Kamal file that `rails new` generates; fill in
your server and registry. SQLite means the only stateful thing to preserve is
the `storage/` volume.
