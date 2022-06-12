Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'positions#index'

  devise_for :users

  resources :positions do
    collection do
      resources :staking, except: [:show]

      post :update_wallet
    end
  end

  resources :transactions, only: [:index]

  # Defines the root path route ('/')
  match '*unmatched_route', to: 'application#not_found', via: :all
end
