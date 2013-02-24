Birdview::Application.routes.draw do
  devise_for :users

  # Static Pages
  get '*id' => 'pages#show', as: :static

  # Root
  root to: 'pages#show', id: 'home'
end
