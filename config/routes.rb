Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  match "(*any)", to: redirect(subdomain: ""), via: :all, constraints: { subdomain: "www" }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # /

  root to: "home#index"

  resources :servers, only: [:index, :show] do
    resources :server_votes, as: "votes", path: "votes", only: [:index, :new, :create]
  end
  resources :server_votes, only: [:show]

  # /users

  scope(path: "users", module: "users", as: "users") do
    get "sign_up",  to: "email_confirmations#new"
    get "sign_in",  to: "sessions#new"
    get "sign_out", to: "sessions#destroy"

    resource  :email_confirmation, only: [:create, :edit, :update]
    resource  :password_reset, only: [:new, :create, :edit, :update]
    resource  :change_email_confirmation, only: [:new, :create, :edit, :update]
    resource  :change_email_reversion, only: [:edit, :update]
    resources :sessions, only: [:create] do
      collection do
        delete "destroy_all", to: "sessions#destroy_all"
      end
    end
  end

  # /admin_users

  scope(path: "admin_users", module: "admin_users", as: "admin_users") do
    get "sign_up",  to: "email_confirmations#new"
    get "sign_in",  to: "sessions#new"
    get "sign_out", to: "sessions#destroy"

    resource  :email_confirmation, only: [:create, :edit, :update]
    resource  :password_reset, only: [:new, :create, :edit, :update]
    resources :sessions, only: [:create] do
      collection do
        delete "destroy_all", to: "sessions#destroy_all"
      end
    end
  end

  # /admin

  constraints(Admin::Constraint.new) do
    scope(path: "admin", module: "admin", as: "admin") do
      root to: "dashboards#show"

      resource  :dashboard, only: [:show]
      resources :users, only: [:index, :show, :edit, :update] do
        get "sessions", on: :member, to: "user_sessions#index"
        get "tokens", on: :member, to: "user_tokens#index"
        get "codes", on: :member, to: "user_codes#index"
      end
      resources :accounts, only: [:index, :show]
      resources :codes, only: [:index, :show]
      resources :admin_codes, only: [:index, :show]
      resources :tokens, only: [:index, :show]
      resources :admin_tokens, only: [:index, :show]
      resources :sessions, only: [:index, :show]
      resources :admin_sessions, only: [:index, :show]
      resources :admin_users do
        get "sessions", on: :member, to: "admin_user_sessions#index"
        get "tokens", on: :member, to: "admin_user_tokens#index"
        get "codes", on: :member, to: "admin_user_codes#index"
      end
      resources :admin_accounts, only: [:index, :show, :edit, :update]
      resources :admin_roles, only: [:index, :show, :edit, :update], path: "roles" do
        get "admin_accounts", on: :member, to: "admin_role_accounts#index"
      end
      resources :admin_permissions, only: [:index, :show], path: "permissions"
      resources :games, except: [:destroy] do
        get "servers", on: :member, to: "game_servers#index"
      end
      resources :feature_flags, except: [:destroy]
      resources :webhook_configs, except: [:destroy] do
        get "batches", on: :member, to: "webhook_config_batches#index"
        get "events", on: :member, to: "webhook_config_events#index"
      end
      resources :webhook_events, only: [:index, :show]
      resources :servers, only: [:index, :show, :edit, :update]
      resources :server_accounts, only: [:index, :show]
      resources :server_stats, only: [:index, :show]
      resources :server_votes, only: [:index, :show]
      resources :webhook_batches, only: [:index, :show]

      constraints(Admin::JobsConstraint.new) do
        mount MissionControl::Jobs::Engine, at: "/jobs"
      end
    end
  end

  # /demo/

  constraints(Demo::Constraint.new) do
    scope(path: "demo", module: "demo", as: "demo") do
      root to: "home#index"

      get "uppertown_8ca7fa4c.json" => "home#uppertown_json"

      resource :webhook_events, only: [:create]
    end
  end

  # /u/

  resources :accounts, path: "u", only: [:show]

  # /i/

  scope(path: "i", module: "inside", as: "inside") do
    root to: "dashboards#show"

    resource :dashboard, only: [:show]
    resource :account, only: [:show]
    resources :servers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :archive
        post :unarchive
        post :mark_for_deletion
        post :unmark_for_deletion
      end
      resources :webhook_configs, only: [:index, :new, :create, :show, :edit, :update]
    end
    resources :server_votes, only: [:index]
  end
end
