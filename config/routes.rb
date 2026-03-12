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

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
