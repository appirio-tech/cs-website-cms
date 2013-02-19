CsWebsiteCms::Application.routes.draw do

  resources :authentications

  get 'protected', to: 'protected#index'

  match '/auth/:provider/callback', to: 'authentications#callback'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
  } do 
    match '/users/registrations/new_third_party', to: 'users/registrations#new_third_party', :as => 'new_third_party_user_registration' 
    get "users/unlock/new",   :to => "users/passwords#unlock"
  end

  get 'members/search'
  get '/community', to: 'members#community'
  get '/leaderboard', to: 'members#leaderboard' # this is temp
  resources :members, only: [:show, :update] do
    member do
      get 'challenges'
      get 'payments'
      get 'recommendations'
      match 'past-challenges' => 'members#past_challenges'
      match 'recommendations' => 'members#create_recommendations', via: [:post]
    end
  end

  get 'challenges/feed' => redirect("/challenges.rss")
  get 'challenges/closed'
  get 'challenges/recent'
  get 'challenges/search'
  resources :challenges, only: [:index, :create, :show, :update] do
    member do
      get 'comments'
      get 'registrants'
      post "comment"
      get 'register'
      match 'agree-tos' => 'challenges#agree_tos'
      get 'watch'
      get 'participants'
      get 'preview'
      get 'submissions'
      get 'submit'
      post 'submit_file'
      post 'submit_url'
      get 'submit_url_or_file_delete'
      get 'results'
      get 'results/scorecard' => 'challenges#results_scorecard', :as => 'scorecard_results'
      get 'scorecard' => redirect {|params| "http://old.cloudspokes.com/challenges/#{params[:id]}/scorecard" }
      get 'survey' => redirect {|params| "http://old.cloudspokes.com/challenges/#{params[:id]}/survey" }
    end

    resource :submission, only: [:show, :update] do
      resources :deliverables, only: [:create, :update, :destroy] do
        collection do
          post "upload"
        end
      end
    end
  end

  namespace :admin do
    resources :challenges, only: [:index, :new, :create, :edit, :update] # remove the restrictions once the new challenges are up
    post 'challenges/assets'
  end

  put '/account', to: 'accounts#update'
  get '/account', to: 'accounts#challenges'
  get '/account/details', to: 'accounts#details'
  get '/account/payment-info', to: 'accounts#payment_info'
  get '/account/school-and-work', to: 'accounts#school_and_work'
  get '/account/public-profile', to: 'accounts#public_profile'
  get '/account/change-password', to: 'accounts#change_password'
  get '/account/challenges', to: 'accounts#challenges'
  get '/account/communities', to: 'accounts#communities'
  get '/account/referred-members', to: 'accounts#referred_members'
  match '/account/invite-friends', to: 'accounts#invite_friends', as: "invite_friends"

  match '/judging/outstanding-reviews', to: 'judging#outstanding_reviews', as: 'outstanding_reviews'
  get '/judging/scorecard/:participant_id', to: 'judging#scorecard', as: 'participant_scorecard'
  post '/judging/scorecard/:participant_id', to: 'judging#scorecard_save', as: 'save_participant_scorecard'
  get '/judging/judging-queue', to: 'judging#judging_queue'
  get '/judging/add_judge/:challenge_id', to: 'judging#add_judge'

  match "leaderboards" => "leaderboards#index"
  match "leaderboards/leaders" => "leaderboards#leaders", as: "leaders"

  get '/forums', to: 'content#forums'
  get '/forums-authenticate', to: 'content#forums_authenticate'  

  match "/blog" => redirect("http://blog.cloudspokes.com")
  match "/help" => redirect("/forums#/categories/help")
  match "/faq" => redirect("/forums#/categories/faqs")
  match "/tos" => redirect("http://content.cloudspokes.com/terms-of-service")
  match "/signup" => redirect("/users/sign_up")
  match "/signin" => redirect("/users/sign_in")
  match "/login" => redirect("/users/sign_in")

  match "/siginup/:username" => redirect("/users/sign_up"), as: "ref_siginup"
  root to: 'refinery/pages#home'

  mount_sextant if Rails.env.development? # https://github.com/schneems/sextant

  # This line mounts Refinery's routes at the root of your application.
  # This means, any requests to the root URL of your application will go to Refinery::PagesController#home.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Refinery relies on it being the default of "refinery"
  mount Refinery::Core::Engine, :at => '/'

end
