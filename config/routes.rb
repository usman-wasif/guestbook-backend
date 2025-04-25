Rails.application.routes.draw do
  resources :comments, only: [:index, :create]
  namespace :admin do
    resources :comments, only: [:index, :destroy] do
      patch 'mark_spam', on: :member
    end
    post 'login', to: 'comments#login'
    delete 'logout', to: 'comments#logout'
  end
end