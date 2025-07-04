# == Route Map
#

Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  devise_scope :user do
    get 'signup', to: 'users/registrations#new', as: :signup
    get 'login', to: 'users/sessions#new', as: :login
    delete 'logout', to: 'users/sessions#destroy', as: :logout
    get 'login_as/:user_id', to: 'users/sessions#login_as'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root to: "objectives#index"

  resources :objectives do
    member do
      patch :move_up
      patch :move_down
    end
  end

  resources :records, only: %i[index new update]
  resource :user_setting, only: %i[show edit update] do
    post :line_test, on:  :collection
  end
  resources :periods

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
