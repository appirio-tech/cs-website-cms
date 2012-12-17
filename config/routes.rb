CsWebsiteCms::Application.routes.draw do

  resources :authentications

  get "protected", to: 'protected#index'

  match '/auth/:provider/callback', to: 'authentications#create'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations'
  }

  get 'members/search'
  resources :members, only: [:index, :show, :update] do
    member do
      get 'challenges'
      get 'payments'
      get 'recommendations'
      match 'recommendations' => 'members#create_recommendations', via: [:post]
    end
  end

  get 'challenges/closed'
  get 'challenges/recent'

  post 'challenges/search'
  get 'challenges/search', to: 'challenges#show_search', as: 'search_searches'

  post 'challenges/populate'
  get 'challenges/populate', to: 'challenges#show_populate'
  resources :challenges, only: [:index, :create, :show, :update] do
    member do
      get 'comments'
      get 'registrants'
    end
  end

  root to: 'refinery/pages#home'

  mount_sextant if Rails.env.development? # https://github.com/schneems/sextant

  # This line mounts Refinery's routes at the root of your application.
  # This means, any requests to the root URL of your application will go to Refinery::PagesController#home.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Refinery relies on it being the default of "refinery"
  mount Refinery::Core::Engine, :at => '/'

end
