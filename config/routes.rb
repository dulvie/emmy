require 'resque/server'
Emmy::Application.routes.draw do

  root 'pages#start'
  devise_for :users, controllers: {sessions: 'user_sessions'}
  [:about, :start, :formats, :test].each do |p|
    get "/#{p}", to: "pages##{p}"
  end

  namespace :api do
    resources :warehouses, :defaults => {:format => 'json'}
    resources :users, :defaults => {:format => 'json'}
    resources :customers, :defaults => {:format => 'json'}
    resources :batches, :defaults => {:format => 'json'}
    resources :manuals, :defaults => {:format => 'json'}
    resources :sales, :defaults => {:format => 'json'}
  end

  namespace :admin do
    resources :organizations
    resources :users
    get 'dashboard', to: 'dashboard#index'
    constraints lambda { |request| request.env['warden'].authenticate? && request.env['warden'].user.superadmin? } do
      mount Resque::Server.new, at: "resque"
    end
  end

  get 'profile/show'
  get 'profile/update'

  get "organization_selector", to: "dashboard#organization_selector"
  get ':organization_slug', to: 'organizations#show', as: 'organization'
  post ':organization_slug', to: 'organizations#update'
  scope ':organization_slug' do
    get "dashboard", to: "dashboard#index"
    resources :batches
    resources :comments
    resources :contact_relations
    resources :contacts
    resources :customers do
      collection do
        get 'name_search', as: :name_search
      end
    end
    resources :documents
    resources :import_batches, only: [:new, :create]
    resources :imports do
      resources :import_batches, only: [:new, :create]
      member do
        post 'state_change', as: :state_change
        get 'new_purchase', as: :new_purchase
        post 'create_purchase', as: :create_pruchase
      end
    end
    resources :inventories do
      resources :inventory_items
      member do
        post 'state_change', as: :state_change
      end
    end
    resources :items
    resources :manuals
    resources :materials
    resources :production_batches, only: [:new, :create]
    resources :productions do
      resources :production_batches, only: [:new, :create]
      resources :materials
      member do
        post 'state_change', as: :state_change
      end
    end
    resources :purchases do
      resources :purchase_items
      member do
        post 'state_change', as: :state_change
      end
      post 'single_purchase', as: :single_purchase
    end
    resources :sales do
      resources :sale_items
      member do
        post 'state_change', as: :state_change
        post 'send_email', as: :send_email
      end
    end
    get 'statistics/index'
    resources :shelves
    resources :suppliers
    resources :transfers do
      member do
        post 'send_package', as: :send_package
        post 'receive_package', as: :receive_package
      end
    end
    resources :units
    resources :users
    resources :vats
    resources :warehouses
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #   root 'controller#action'

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
