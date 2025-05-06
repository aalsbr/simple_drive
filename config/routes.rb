Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # API routes
  namespace :api do
    namespace :v1 do
      # POST /v1/blobs - Store blob by id
      post 'blobs', to: 'blobs#create'
      
      # GET /v1/blobs/:id - Retrieve blob by id
      get 'blobs/:id', to: 'blobs#show'
      
      # POST /v1/tokens - Generate JWT token
      post 'tokens', to: 'tokens#create'
    end
  end
  
  # Healthcheck route
  get '/health', to: 'health#index'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
