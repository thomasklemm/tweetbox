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
    resources :projects, only: [:index, :new, :create, :edit, :update], controller: 'account/projects'

    resources :users, only: [:index, :show, :edit, :update], path: 'team', controller: 'account/users' do
      put :upgrade_to_admin, on: :member
    end

    resources :invitations, only: [:index, :new, :create, :edit, :update], controller: 'account/invitations' do
      member do
        put :deactivate
        put :reactivate

        post :deliver_mail
      end
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
      post 'auth', as: :authorize, on: :collection

      member do
        post 'default'
        get 'import', action: 'get_import'
        post 'import', action: 'post_import'
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

  # Root
  root to: 'high_voltage/pages#show', id: 'landing'
end
