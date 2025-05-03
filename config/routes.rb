Rails.application.routes.draw do
  get "portfolios/show"
  get "transactions/new"
  get "transactions/create"
  get "transactions/index"
  get "stocks/index"
  get "users/new"
  get "sessions/new"
  get "sessions/destroy"
  get "welcome/index"
  get "home/index"

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/admin/dashboard', to: 'admins#dashboard', as: 'admin_dashboard'
  patch '/admin/promote/:id', to: 'admins#promote', as: 'promote_user'
  get '/trader/dashboard', to: 'users#dashboard', as: 'trader_dashboard'
  get '/transactions', to: 'transactions#index', as: 'transactions'
  resources :transactions, only: [:new, :create, :index]
  get '/portfolio', to: 'portfolios#show', as: 'portfolio'

  get '/stocks', to: 'stocks#index', as: 'stocks'

  root "welcome#index"
end
