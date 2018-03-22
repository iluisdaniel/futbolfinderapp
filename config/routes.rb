Rails.application.routes.draw do
  mount StripeEvent::Engine, at: '/webhooks/stripe'

  get 'sessions/new'

  root             'static_pages#home'
  get 'help'    => 'static_pages#help'
  get 'about'   => 'static_pages#about'
  
  get 'b/businesses' => 'businesses#index'
  get 'b/signup'  => 'businesses#new'
  get 'b/stripe_connect' => 'businesses#stripe_connect'
  get 'b/confirmation' => 'businesses#confirmation'

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  get 'u/signup' => 'users#new'
  get 'u/users' => 'users#index'

  get 'available_fields' => 'available_fields#index'
  get 'select_game' => 'select_game#index'
  get 'confirmation' => 'reservations#confirmation'
  # post 'confirmed' => 'reservations#confirmed'

  resource :subscription
  resource :payment_method
  resources :charges

  resources :notifications, only: :index

  namespace "reservations" do
    resources :past, only: :index
  end

  resources :reservations
  resources :custom_venues, only: [:new, :create, :destroy]

  namespace "games" do
    resources :old_games, only: :index
    resources :upcoming_games, only: :index
    resources :planning, only: :index
    resources :invited, only: :index
  end

  resources :games, path: '/games/' do 
    resources :comments, module: :games
    member do
      resources :conversation, only: :index, module: :games
      resources :players, only: :index, module: :games 
    end
  end

  resources :game_lines, only: [:create, :update,:destroy]

  resources :schedules, only: [:create, :destroy]
  resources :fields, only: [:create, :update, :destroy]
  resources :businesses, path: '/b/'
  
  resources :users, path: '/u/' do
    member do 
      resources :friends, only: :index, module: :users
      resources :pending_friends, only: :index, module: :users
      resources :requests, only: :index, module: :users
      resources :user_games, only: :index, module: :users
    end
    
  end
  resources :friendships, only: [:create, :update, :destroy]

  # namespace :users, path: '/friends/' do
  #   resources :friends, only: :index, as: ""
  # end

  resources :groups, path: '/groups/' do 
    resources :comments, module: :groups
  end 
  resources :group_lines, only: [:create, :destroy]
  

  # Get routes in the shell: bundle exec rake routes

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end