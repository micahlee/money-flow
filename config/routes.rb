Rails.application.routes.draw do
  
  devise_for :users

  scope '/admin' do
    resources :users
    resources :families
  end

  root "home#index"

  scope '/families/:family_id' do
    get '/', to: 'dashboard#index', as: 'dashboard'

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

    resources :funds do
      post 'clear_all_pending', on: :member
    end

    get '/money-mover', to: 'money_mover#index'
    
    get '/transactions', to: 'transactions#all'

    get '/review', to: 'transactions#review'
    
    get '/credit_cards', to: 'credit_cards#index'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
