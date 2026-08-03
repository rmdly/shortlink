Rails.application.routes.draw do
  root "links#index"

  resources :links, only: %i[ index show create destroy ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # The short link itself. Declared last so it only catches what nothing else
  # claimed, and constrained so it never swallows an asset path.
  get "/:slug" => "redirects#show", as: :short, constraints: { slug: Link::SLUG_PATTERN }
end
