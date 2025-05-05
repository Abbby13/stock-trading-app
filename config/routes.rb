Rails.application.routes.draw do
  get "portfolios/show"
  resources :transactions, only: [:index, :new, :create]

  # get "transactions/new"
  # get "transactions/create"
  # get "transactions/index"
  get "stocks/index"
  get "users/new"
  get "sessions/new"
  get "sessions/destroy"
  get "welcome/index"
  get "home/index"

  
  get '/admin/dashboard', to: 'admins#dashboard', as: 'admin_dashboard'

  get '/admin/traders', to: 'admins#traders_index', as: 'admin_traders'
  get '/admin/traders/new', to: 'admins#trader_new', as: 'new_admin_trader'
  post '/admin/traders', to: 'admins#trader_create'
  get '/admin/traders/:id', to: 'admins#trader_show', as: 'admin_trader'
  get '/admin/traders/:id/edit', to: 'admins#trader_edit', as: 'edit_admin_trader'
  patch '/admin/traders/:id', to: 'admins#trader_update'

  get '/admin/pending_traders', to: 'admins#pending_traders', as: 'admin_pending_traders'
  patch '/admin/traders/:id/approve', to: 'admins#approve', as: 'approve_admin_trader'

  get '/admin/transactions', to: 'admins#transactions_index', as: 'admin_transactions'

  patch '/admin/promote/:id', to: 'admins#promote', as: 'promote_user'
  patch '/admin/demote/:id', to: 'admins#demote', as: 'demote_user'

  # Authentication routes
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'

  # Trader dashboard
  get '/trader/dashboard', to: 'users#dashboard', as: 'trader_dashboard'
  
  
  # Portfolio route
  get '/portfolio', to: 'portfolios#show', as: 'portfolio'

  # Stocks route
  get '/stocks', to: 'stocks#index', as: 'stocks'

  resource :portfolio, only: :show do
    member do
      get  :deposit
      post :deposit,   to: 'portfolios#perform_deposit'
      get  :withdraw
      post :withdraw,  to: 'portfolios#perform_withdraw'
    end
  end

  resources :transactions, only: [:new, :create, :index] do
    member do
      get :confirmation
    end   # closes member
  end    

  root to: redirect("/trader/dashboard")
end
