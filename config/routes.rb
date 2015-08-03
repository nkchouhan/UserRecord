require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq"
  
  devise_for :users
  root :to => 'admin/user_records#home'
  
  namespace "admin" do
    get '/' => 'user_records#home', as: :root
    resources :user_records do
      collection do
        post 'upload'
        post 'download'
      end
    end
  end

end
