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
    resources :statuses, only: [:new, :create]

    resources :tweets, only: :show do
      collection do
        get '/' => 'tweets#index' # state1
        get '/state2' => 'tweets#index'
        get '/state3?page=123' => 'tweets#index'
      end

      member do
        put  'transition' => 'tweets#transition' # transition_project_tweet_path(@project, @tweet, to: :opened/:closed)

        resources :reweets,   controller: 'tweets/retweets',  only: [:new, :create]
        resources :favorites, controller: 'tweets/favorites', only: [:new, :create]
      end
    end

    resources :authors, only: :show


    resources :twitter_accounts, only: [:index, :new, :destroy] do
      post 'auth', on: :collection, as: :authorize
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
