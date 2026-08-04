Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  namespace :admin do
    resources :businesses
    resources :admin_users
  end

  resources :store_locations
  resources :users

  resources :customers do
    get :tree, on: :collection
  end
  resources :suppliers

  resources :categories
  resources :products do
    resources :variants, controller: "product_variants", shallow: true
  end
  resources :product_variants, only: %i[index show], as: :all_variants
  resources :stocks, only: %i[index show] do
    post :adjust, on: :collection
  end
  resources :inventory_items do
    post :update_status, on: :member
  end

  resources :carts do
    post :add_line, on: :member
    delete :remove_line, on: :member
    post :convert, on: :member
  end

  resources :sales_orders do
    resources :payments, only: %i[new create], controller: "payments", shallow: true
    post :post, on: :member
    post :complete, on: :member
    post :cancel, on: :member
  end

  resources :sales_returns do
    post :complete, on: :member
  end

  resources :purchase_orders do
    get :receive, on: :member
    post :receive, on: :member
    post :submit, on: :member
    post :approve, on: :member
    post :cancel, on: :member
  end

  resources :purchase_returns do
    post :complete, on: :member
  end

  resources :transfer_orders do
    post :approve, on: :member
    post :ship, on: :member
    post :receive, on: :member
    post :cancel, on: :member
  end

  resources :service_asset_categories do
    resources :fields, controller: "service_asset_fields", shallow: true
  end

  resources :service_assets do
    get :search, on: :collection
  end

  resources :work_orders do
    post :transition, on: :member
    post :consume_part, on: :member
    post :receive_item, on: :member
    post :return_item, on: :member
    post :add_task, on: :member
    post :add_part, on: :member
    post :add_service, on: :member
    post :add_charge, on: :member
  end

  resources :cash_registers
  resources :cash_sessions do
    post :close, on: :member
    post :add_cash, on: :member
  end

  resources :ledgers do
    resources :accounts
  end
  resources :journal_entries do
    post :reverse, on: :member
  end
end
