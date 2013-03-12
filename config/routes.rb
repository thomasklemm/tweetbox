Birdview::Application.routes.draw do
  # User authentication
  devise_for :users,
    path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' },
    controllers: {
      registrations: 'users/registrations'
    }

  # Special naming of signup, login and logout routes
  devise_scope :user do
    get 'login',     to: 'devise/sessions#new',      as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy',  as: :destroy_user_session
  end

  get 'login', to: 'devise/sessions#new', as: :login

  # Signups
  get 'signup' => 'signups#new',     as: :new_signup
  post 'signup' => 'signups#create', as: :signups

  # Invitations
  namespace :invitations do
    resources :registrations, only: [:new, :create]
    resources :joins, only: [:new, :create]
  end

  resources :accounts do
    resources :projects, except: [:index, :show]
    resources :invitations, only: [:index, :new, :create, :destroy] do
      put :send_email, on: :member, as: :send
    end
  end

  resources :projects, only: [:index, :show] do
    resources :twitter_accounts, only: [:index, :show, :new] do
      post 'auth', on: :collection, as: :authorize
    end
    resources :searches
    resources :tweets
  end

  # Omniauth to authorize Twitter accounts
  #  There is a hidden 'auth/twitter' path too that requests can be directed to
  #  when trying to authorize a Twitter account with this application
  match 'auth/twitter/callback' => 'omniauth#twitter'
  match 'auth/failure'          => 'omniauth#failure'

  # Static Pages
  get '*id' => 'pages#show', as: :static

  # Root
  root to: 'pages#show', id: 'home'
end
