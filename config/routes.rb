require 'sidekiq/web'

Birdview::Application.routes.draw do
  # User authentication
  devise_for :users,
    path_names: { sign_in: 'login', sign_out: 'logout' }

  # Special naming of user authentication routes
  devise_scope :user do
    get 'login',     to: 'devise/sessions#new',      as: :login
    get 'login',     to: 'devise/sessions#new',      as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy',  as: :logout
    delete 'logout', to: 'devise/sessions#destroy',  as: :destroy_user_session
  end

  # Signups
  get  'signup' => 'signups#new',    as: :new_signup
  post 'signup' => 'signups#create', as: :signups

  # Registrations
  get  'register' => 'registrations#new',    as: :new_registration
  post 'register' => 'registrations#create', as: :registrations

  # Accounts
  resource :account do
    resources :invitations, only: [:new, :create, :destroy] do
      post :deliver_mail, on: :member
    end
  end

  # Projects
  resources :projects do
    # Tweets
    resources :tweets, only: :show do
      collection do
        get ''         => :index, as: :incoming
        get 'open'     => :index, as: :open
        get 'resolved' => :index, as: :resolved
      end

      member do
        put  'transition'
      end

      resources :replies,   only: [:new, :create], on: :member, controller: 'statuses'
      resources :retweets,  only: [:new, :create], on: :member
      resources :favorites, only: [:new, :create], on: :member
      resources :comments,  only: [:new, :create], on: :member
    end

    resources :statuses, only: [:new, :create]

    resources :twitter_accounts, only: [:index, :new, :destroy] do
      collection do
        post 'auth', as: :authorize
      end
    end

    resources :searches, except: :show
  end



  # Omniauth to authorize Twitter accounts
  #  There is a hidden 'auth/twitter' path too that requests can be directed to
  #  when trying to authorize a Twitter account with this application
  match 'auth/twitter/callback' => 'omniauth#twitter'
  match 'auth/failure'          => 'omniauth#failure'

  # Sidekiq Web interface
  mount Sidekiq::Web => '/sidekiq'

  # Static Pages
  get '*id' => 'pages#show', as: :static

  # Root
  root to: 'projects#index'
end
