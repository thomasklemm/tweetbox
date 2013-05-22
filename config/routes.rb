require 'sidekiq/web'

Birdview::Application.routes.draw do
  get "statuses/new"

  get "statuses/create"

  # User authentication
  devise_for :users,
    path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' },
    controllers: { registrations: 'users/registrations', passwords: 'users/passwords' }

  # Special naming of user authentication routes
  devise_scope :user do
    get 'login',     to: 'devise/sessions#new',      as: :login
    get 'login',     to: 'devise/sessions#new',      as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy',  as: :logout
    delete 'logout', to: 'devise/sessions#destroy',  as: :destroy_user_session
    get 'register',  to: 'devise/registrations#new', as: :new_user_registration
  end

  # Signups
  get  'signup' => 'signups#new',    as: :new_signup
  post 'signup' => 'signups#create', as: :signups

  # Registrations
  get  'register' => 'registrations#new',    as: :new_registration
  post 'register' => 'registrations#create', as: :registrations

  # Invitations
  get 'invitations/accept' => 'accept_invitations#accept', as: :accept_invitation

  # Accounts
  resources :accounts do
    resources :projects, except: [:index, :show]
    resources :invitations, only: [:index, :new, :create, :destroy] do
      put :send_mail, on: :member, as: :send
    end
  end

  # Projects
  resources :projects, only: [:index, :show] do
    resources :tweets, only: [:index, :show] do
      get 'conversation', on: :member

      # State transitions
      put 'mark_as_open', on: :member
      put 'mark_as_closed', on: :member

      resources :replies,   controller: 'tweets/replies',  only: [:new, :create]
      resources :comments,  controller: 'tweets/comments', only: [:new, :create]
      resources :retweets,  controller: 'tweets/retweets', only: [:new, :create]
      resources :favorites, controller: 'tweets/favorites', only: [:new, :create]
    end

    resources :twitter_accounts, only: [:index, :new, :destroy] do
      post 'auth', on: :collection, as: :authorize
    end

    resources :searches, only: [:index, :new, :create, :edit, :update, :destroy]
  end

  # Statuses
  resources :statuses

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
