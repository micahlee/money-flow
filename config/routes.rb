Rails.application.routes.draw do
  resources :connections do
    post 'access_token', on: :collection

    post 'sync_accounts', on: :member

    resources :accounts do
      resources :transactions do
        post 'clear', on: :member
        post 'assign', on: :member

        get 'split', on: :member, to: 'transactions#split_form'
        post 'split', on: :member
      end

      post 'sync_transactions', on: :member
    end

    post 'sync_all', on: :collection
  end

  resources :funds

  get '/money-mover', to: 'money_mover#index'

  root "dashboard#index"
  get '/dashboard', to: 'dashboard#index'
  get '/transactions', to: 'transactions#all'

  get '/review', to: 'transactions#review'
  
  get '/credit_cards', to: 'credit_cards#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
