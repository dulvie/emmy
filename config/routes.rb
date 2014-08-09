require 'resque/server'
Emmy::Application.routes.draw do

  resources :transfers do
    member do
      post 'send_package', as: :send_package
      post 'receive_package', as: :receive_package
    end
  end

  resources :comments
  resources :contacts
  resources :customers do
    collection do
      get 'name_search', as: :name_search
    end
  end  
  resources :documents
  resources :imports do
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
  resources :units
  resources :vats
  resources :materials
  resources :productions do
    resources :materials
    member do
      post 'state_change', as: :state_change
    end
  end
  resources :suppliers
  resources :sales do
    resources :sale_items
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
  resources :products
  get "statistics/index"
  resources :warehouses
  devise_for :users
  resources :users do
    member do
      get "edit_roles", to: "users#edit_roles"
      patch "edit_roles", to: "users#update_roles" 
    end
  end
  
  get "dashboard", to: "dashboard#index"
  [:about,:start,:formats, :test].each do |p|
    get "/#{p}", to: "pages##{p}"
  end
  constraints lambda { |request| request.env['warden'].authenticate? && request.env['warden'].user.role?(:admin) } do
    mount Resque::Server.new, at: "/resque"
  end

  namespace :api do
    resources :warehouses, :defaults => {:format => 'json'}
    resources :users, :defaults => {:format => 'json'}
    resources :customers, :defaults => {:format => 'json'}
    resources :products, :defaults => {:format => 'json'}
    resources :manuals, :defaults => {:format => 'json'}
    resources :sales, :defaults => {:format => 'json'}
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#start'

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
