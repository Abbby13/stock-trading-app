Rails.application.routes.draw do
  get "users/new"
  get "users/create"
  get "sessions/new"
  get "sessions/create"
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
  delete '/logout', to: 'sessions#destroy'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "welcome#index"
end
