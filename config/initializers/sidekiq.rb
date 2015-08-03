require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["yelpscraper", "$$ttopt?;}{_+=)(G)Tm{|}st.,//?"]
end