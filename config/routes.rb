Birdview::Application.routes.draw do
  # User authentication
  devise_for :users,
    path_names: { sign_up: 'signup', sign_in: 'login', sign_out: 'logout' },
    controllers: { registrations: 'user_registrations' }

  # Special naming of signup, login and logout routes
  devise_scope :user do
    get 'login',     to: 'devise/sessions#new',      as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy',  as: :destroy_user_session
  end

  get 'login', to: 'devise/sessions#new', as: :login

  # Signups
  get 'signup' => 'signups#new',     as: :new_signup
  post 'signup' => 'signups#create', as: :signups

  resources :accounts do
    resources :projects, except: [:index, :show]
  end

  resources :projects, only: [:index, :show] do
    resources :twitter_accounts
    resources :searches
    resources :tweets
  end

  # Static Pages
  get '*id' => 'pages#show', as: :static

  # Root
  root to: 'pages#show', id: 'home'
end
