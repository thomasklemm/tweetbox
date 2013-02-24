Birdview::Application.routes.draw do
  devise_for :users

  # Static Pages
  get '*id' => 'pages#show', as: :page

  # Root
  root to: 'pages#show', id: 'home'
end
