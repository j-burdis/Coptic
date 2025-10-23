Rails.application.routes.draw do
  # Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Root
  root to: "pages#home"

  # Static pages
  get 'contact', to: 'pages#contact'
  get 'copyright-permissions', to: 'pages#copyright_permissions'
  get 'privacy', to: 'pages#privacy'
  get 'newsletter', to: redirect('https://howard-hodgkin.us2.list-manage.com/subscribe?u=0456cc82d5128b6c05f63f584&id=29ec9d6d8b')

  # Search
  get 'search', to: 'search#index'

  # Mailing list
  get 'subscribe', to: 'subscriptions#new'
  post 'subscribe', to: 'subscriptions#create'

  # Main collection - gallery/artworks
  namespace :gallery do

    get '/', to: 'artworks#index', as: :root

    get 'paintings', to: 'artworks#paintings'
    get 'prints', to: 'artworks#prints'
    get 'indian-leaves', to: 'artworks#indian_leaves'
    get 'indian-waves', to: 'artworks#indian_waves'
    get 'quantel-paintbox', to: 'artworks#quantel_paintbox'
    get 'memories-of-bombay-mumbai', to: 'artworks#memories_of_bombay_mumbai'
    get 'other', to: 'artworks#other'

    # Special status collections
    get 'missing-works', to: 'artworks#missing_works'
    get 'destroyed', to: 'artworks#destroyed'

    # Design with subcategories
    get 'design', to: 'artworks#design'
    get 'design/:subcategory', to: 'artworks#design_subcategory', 
        as: :design_subcategory

    get 'all', to: 'artworks#all'
  end

  # Individual artwork - cleaner URL outside of namespace
  get 'artwork/:slug', to: 'artworks#show', as: :artwork
  
  # Main collection - resources
  namespace :resources do
    get '/', to: 'pages#index', as: :root

    get 'films-and-audio', to: 'resources#films_and_audio'

    get 'texts', to: 'resources#texts'
    get 'texts/:subcategory', to: 'resources#texts_subcategory',
        as: :texts_subcategory,
        constraints: { subcategory: /(critical-essays|interviews|selected-reviews|the-artists-words)/ }
    
    get 'publications', to: 'resources#publications'
    get 'publications/:subcategory', to: 'resources#publications_subcategory',
        as: :publications_subcategory,
        constraints: { subcategory: /(posters-postcards|selected-books|selected-catalogues)/ }
    
    get 'chronology', to: 'resources#chronology'

    get 'collections', to: 'collections#index'    
  end

  # Individual resource - cleaner URL outside of namespace
  get 'resource/:slug', to: 'resources#show', as: :resource

  # Individual collection - cleaner URL outside of namespace
  get 'collection/:slug', to: 'collections#show', as: :collection

  # Exhibitions
  get 'exhibitions', to: 'exhibitions#index', as: :exhibitions
  
  get 'exhibitions/:exhibition_type', to: 'exhibitions#by_type',
      as: :exhibitions_by_type,
      constraints: { exhibition_type: /(solo-shows|group-shows|paintings|prints|other)/ }
  
  get 'exhibition/:slug', to: 'exhibitions#show', as: :exhibition

  # News
  resources :news, only: [:index, :show], param: :slug

  # Indian Collection
  namespace :indian_collection, path: 'indian-collection' do
    get '/', to: 'pages#index', as: :root
   
    # Gallert/Artworks with categories
    namespace :gallery do
      get '/', to: 'artworks#index', as: :root
      get 'portrait', to: 'artworks#portrait'
      get 'elephants', to: 'artworks#elephants'
      get 'flora-fauna', to: 'artworks#flora_fauna'
    end
    
    # List of resources
    get 'resources', to: 'resources#index'
    
    # Exhibition list - static page
    get 'exhibition/exhibition-list', to: 'exhibitions#list'
  end

  # Individual Indian Collection items - cleaner URL outside of namespace
  get 'indian-collection/artwork/:slug', to: 'indian_collection/artworks#show', 
      as: :indian_collection_artwork
  get 'indian-collection/resource/:slug', to: 'indian_collection/resources#show', 
      as: :indian_collection_resource
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
