Rails.application.routes.draw do
  root "emails#index"
  resources :emails, only: [:index] do
    collection do
      get :count
      get :subjects
      get :stats
      get :sync_emails
      get :dashboard
    end
  end
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  devise_scope :user do
    get "users/sign_in", to: "users/sessions#new", as: :new_user_session
    get "users/sign_out", to: "users/sessions#destroy", as: :destroy_user_session
  end
  get "up" => "rails/health#show", :as => :rails_health_check
end
