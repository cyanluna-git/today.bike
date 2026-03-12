Rails.application.routes.draw do
  devise_for :admin_users

  namespace :admin do
    root "dashboard#index"
    resources :customers do
      member do
        get :bicycles
      end
    end
    resources :bicycles do
      member do
        delete "photos/:photo_id", action: :purge_photo, as: :purge_photo
        get :qr_code
        get :qr_print
      end
      resources :bicycle_specs, only: %i[new create edit update destroy]
      resources :fitting_records
    end
    resources :service_orders do
      collection do
        get :kanban
      end
      member do
        patch :update_status
      end
      resources :service_photos, only: %i[create destroy]
      resources :repair_logs, only: %i[create edit update destroy]
      resources :parts_replacements, only: %i[create edit update destroy]
      resources :upgrades, only: %i[create edit update destroy]
      resources :frame_changes, only: %i[create edit update destroy]
    end
    resources :imports, only: %i[new create]
    resources :blog_posts
    resources :products
    resources :rentals do
      resources :rental_bookings
    end
  end

  namespace :portal do
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    get "auth/kakao/callback", to: "sessions#kakao_callback"

    root "bicycles#index"
    resources :bicycles, only: %i[index show]
    resources :service_orders, only: %i[index show]
    resources :fitting_records, only: %i[index show]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Public products
  resources :products, only: %i[index show]

  # Public rentals
  resources :rentals, only: %i[index show] do
    member do
      post :create_booking
      get :booking_confirmation
    end
  end

  # Public blog
  get "blog", to: "blog#index", as: :blog
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Public gallery
  get "gallery", to: "gallery#index", as: :gallery

  # Public bicycle passport (no auth required)
  get "passport/:token", to: "passports#show", as: :passport

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
