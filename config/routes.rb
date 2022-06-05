Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'positions#index'

  devise_for :users

  resources :positions do
    collection do
      post :update_wallet

      get :staking
      post :staking, action: 'create_staking'
      patch 'stake/:id', action: 'update_staking', as: :staked
      delete 'stake/:id', action: 'destroy_staking'
    end
  end

  resources :transactions, only: [:index]

  # Defines the root path route ('/')
  match '*unmatched_route', to: 'application#not_found', via: :all
end
