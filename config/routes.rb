CsWebsiteCms::Application.routes.draw do

  resources :authentications

  match "/appirio" => redirect("/communities/appirio")
  match "/appirio/leaderboard" => redirect("/communities/appirio/leaderboard")
  match '/auth/:provider/callback', to: 'authentications#callback'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
  } do 
    match '/users/registrations/new_third_party', to: 'users/registrations#new_third_party', :as => 'new_third_party_user_registration' 
    match '/signup/:id', to: 'users/registrations#referral', :as => 'referral'
    match '/signup', to: 'users/registrations#signup', :as => 'signup' 
    get "users/unlock/new",   :to => "users/passwords#unlock"
  end

  get '/members' => redirect("/community")
  get '/dashboard', to: 'members#community'
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
  get 'challenges/feed/recent' => redirect("/challenges/recent.rss")  
  get 'challenges/closed' => redirect("/challenges")
  get 'challenges/recent'
  match 'challenges/search' => 'challenges#search', :as => 'advanced_challenge_search'
  get 'challenges/index' # support for old urls: /challenges/index?category=JavaScript
  resources :challenges, only: [:index, :create, :show, :update] do
    member do
      get 'comments'
      post "comment"
      get 'register'
      match 'agree-tos' => 'challenges#agree_tos', :as => 'agree_tos'
      get 'watch'
      get 'participants'
      get 'preview'
      get 'submissions'
      get 'all_submissions' => redirect {|params| "/challenges/#{params[:id]}/submissions" }      
      get 'cal' => 'challenges#submissions'
      get 'registrants' => redirect {|params| "/challenges/#{params[:id]}/participants" }
      get 'papertrail'
      get 'submit'
      put 'submit_details'
      post 'submit_file'
      post 'submit_url'
      get 'submit_url_or_file_delete'
      get 'results'
      get 'appeals'
      get 'results/scorecard' => 'challenges#results_scorecard', :as => 'scorecard_results'
      get 'scorecard'
      match 'survey' => "challenges#survey", :as => 'survey'
    end

    resource :submission, only: [:show, :update] do
      resources :deliverables, only: [:create, :update, :destroy] do
        collection do
          post "upload"
          delete "destroy"
        end
      end
    end
  end

  get "/messages"                  => redirect("/messages/inbox"), :via => :get
  get "/messages/inbox"            => 'messages#index'
  get "/messages/:id"              => 'messages#show', :as => :messages_show
  match "/messages"                => "messages#create", :as => :messages, :via => :post
  match "/messages/:id/reply"      => "messages#reply", :as => :message_reply, :via => :post

  get "/communities/:id/leaderboard"              => 'communities#leaderboard', :as => :community_leaderboard
  resources :communities, only: [:show]
  resources :events, only: [:show]

  namespace :admin do
    resources :challenges, only: [:index, :create, :edit, :update] # remove the restrictions once the new challenges are up
    post 'challenges/assets'
    match 'challenges/delete_asset' => 'challenges#delete_asset', :as => 'delete_asset'
  end

  put '/account', to: 'accounts#update'
  get '/account', to: 'accounts#challenges'
  get '/account/details', to: 'accounts#details'
  get '/account/payment-info', to: 'accounts#payment_info', as: "payment_info"
  get '/account/school-and-work', to: 'accounts#school_and_work'
  get '/account/public-profile', to: 'accounts#public_profile'
  get '/account/change-password', to: 'accounts#change_password'
  get '/account/challenges', to: 'accounts#challenges'
  get '/account/past-challenges', to: 'accounts#past_challenges', :as => 'account_past_challenges'
  get '/account/communities', to: 'accounts#communities'
  get '/account/referred-members', to: 'accounts#referred_members'
  match '/account/invite-friends', to: 'accounts#invite_friends', as: "invite_friends"
  get '/account/activities', to: 'accounts#activities'
  match '/account/preferences', to: 'accounts#preferences'  

  match '/judging/outstanding-reviews', to: 'judging#outstanding_reviews', as: 'outstanding_reviews'
  get '/judging/scorecard/:participant_id', to: 'judging#scorecard', as: 'participant_scorecard'
  post '/judging/scorecard/:participant_id', to: 'judging#scorecard_save', as: 'save_participant_scorecard'
  get '/judging/judging-queue', to: 'judging#judging_queue'
  get '/judging/add_judge/:challenge_id', to: 'judging#add_judge'
  get '/judging/download_all_assets/:participant_id', to: 'judging#download_all_assets', as: 'download_all_assets'  

  match "leaderboards" => "leaderboards#index"
  match "leaderboards/leaders" => "leaderboards#leaders", as: "leaders"

  resources :requirements

  get '/search', to: 'content#search'
  get '/madison', to: 'content#madison'
  get '/forums', to: 'content#forums'
  get '/forums-authenticate', to: 'content#forums_authenticate'
  get '/bad', to: 'content#bad'  
  get '/whoops', to: 'content#whoops'  
  get '/corona', to: 'content#corona'  

  get '/admin', to: 'admin#index'
  get '/admin/blog_fodder'
  get '/admin/loadrss'
  post '/admin/cms'

  match "/blog" => redirect("http://blog.cloudspokes.com")
  match "/help" => redirect("/forums#/categories/help")
  match "/faq" => redirect("/forums#/categories/faqs")
  match "/tos" => redirect("/terms-of-service")
  match "/signup" => redirect("/users/sign_up")

  get "/docusign/embedded_signing", to: "docusign#embedded_signing", as: "docusign_signing"
  get "/docusign/response", to: "docusign#docusign_response", as: "docusign_response"

  root to: 'refinery/pages#home'

  mount_sextant if Rails.env.development? # https://github.com/schneems/sextant

  mount Resque::Server, :at => "/resque"

  mount Refinery::Core::Engine, :at => '/'

end
