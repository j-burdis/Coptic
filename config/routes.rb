Rails.application.routes.draw do
  get "subscriptions/new"
  get "subscriptions/create"
  get "search/index"
  get "news/index"
  get "news/show"
  namespace :resources do
    get "collections/index"
    get "collections/show"
  end
  get "exhibitions/index"
  get "exhibitions/show"
  get "resources/index"
  get "resources/show"
  get "resources/films_and_audio"
  get "resources/texts"
  get "resources/publications"
  get "resources/chronology"
  get "artworks/index"
  get "artworks/show"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
