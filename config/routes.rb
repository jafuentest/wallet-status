Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ('/')
  root 'positions#index'

  authenticated :user, -> user { user.id == 1 } do
    mount Delayed::Web::Engine, at: '/jobs'
  end

  devise_for :users

  resources :positions, only: [:index] do
    collection do
      resources :staking, except: [:show]

      post :update_wallet
    end
  end

  resources :transactions, only: [:index]

  match '*unmatched_route', to: 'application#not_found', via: :all
end
