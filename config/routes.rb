Rails.application.routes.draw do
  resources :comments, only: [:index, :create]
  namespace :admin_panel do
    resources :comments, only: [:index, :destroy] do
      patch 'mark_spam', on: :member
    end
  end
end