require 'sidekiq/web'

Tweetbox::Application.routes.draw do
  # User authentication
  devise_for :users,
    path_names: { sign_in: 'login', sign_out: 'logout' }

  # Special naming of user authentication routes
  devise_scope :user do
    get 'login',     to: 'devise/sessions#new',      as: :login
    delete 'logout', to: 'devise/sessions#destroy',  as: :logout
    # get 'login',     to: 'devise/sessions#new',      as: :new_user_session
    # delete 'logout', to: 'devise/sessions#destroy',  as: :destroy_user_session
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
    resources :tweets, only: [:index, :show] do
      collection do
        get ''         => :incoming, as: :incoming
        get 'resolved' => :resolved
        get 'posted'   => :posted
      end

      member do
        post 'resolve'
        post 'activate'
      end

      resources :replies,   only: [:new, :create], on: :member, controller: 'statuses'
      resources :retweets,  only: [:new, :create], on: :member
      resources :favorites, only: [:new, :create], on: :member
    end

    resources :statuses, only: [:new, :create]
    resources :authors, only: :show

    resources :twitter_accounts, only: [:index, :new, :destroy] do
      post :auth, as: :authorize, on: :collection
      put :set_default, on: :member
    end

    resources :searches, except: :show
  end

  # Public view
  get 't/:code_id' => 'public/codes#redirect', as: :public_code
  get 'tweets/:screen_name/:twitter_id' => 'public/tweets#show', as: :public_tweet

  # Omniauth to authorize Twitter accounts
  #  There is a hidden 'auth/twitter' path too that requests can be directed to
  #  when trying to authorize a Twitter account with this application
  match 'auth/twitter/callback' => 'omniauth#twitter', via: [:get, :post]
  match 'auth/failure'          => 'omniauth#failure', via: [:get, :post]

  # Dash
  namespace :dash do
    resources :leads, only: [:show, :update, :destroy] do
      collection do
        get :search
        post :remember
        get 'score', to: redirect('/leads/score/unscored'), as: :unscored
        get 'score/:score', to: :score, as: :score
      end

      member do
        post :refresh
      end
    end

    root 'leads#search'
  end

  # Sidekiq Web interface
  mount Sidekiq::Web => '/sidekiq'

  # Marketing pages
  get ':id' => 'pages#show', as: :static

  # Root
  root 'pages#show', id: 'landing'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
