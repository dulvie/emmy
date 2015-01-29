require 'resque/server'
Emmy::Application.routes.draw do
  get 'profile', to: 'profile#show'
  patch 'profile', to: 'profile#update'

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
    resources :users do
      member do
        patch 'update_roles', as: :update_roles
      end
    end
    get 'dashboard', to: 'dashboard#index'
    constraints lambda { |request| request.env['warden'].authenticate? && request.env['warden'].user.superadmin? } do
      mount Resque::Server.new, at: "resque"
    end
  end


  get "organization_selector", to: "dashboard#organization_selector"
  get ':organization_slug', to: 'organizations#show', as: 'organization'
  patch ':organization_slug', to: 'organizations#update'
  scope ':organization_slug' do
    get "dashboard", to: "dashboard#index"

    resources :accounting_periods do
      member do
        post 'import_sie', as: :import_sie_files
      end
    end

    post 'accounting_plan_import', to: 'accounting_plans#import', as: 'accounting_plan_import'
    resources :accounting_plans do
      resources :accounting_groups
      resources :accounting_classes
      resources :accounts
    end
    resources :batches
    resources :closing_balances do
      resources :closing_balance_items
    end
    resources :comments
    resources :contact_relations
    resources :contacts
    resources :customers do
      collection do
        get 'name_search', as: :name_search
        get 'city_search', as: :city_search
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
    resources :ink_codes
    resources :inventories do
      resources :inventory_items
      member do
        post 'state_change', as: :state_change
      end
    end
    resources :items
    resources :ledgers do
      resources :ledger_accounts
    end
    resources :ledger_transactions
    resources :manuals
    resources :materials
    resources :opening_balances do
      post 'create_from_ub'
      resources :opening_balance_items
      member do
        post 'state_change', as: :state_change
      end
    end
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
        post 'regenerate_invoice', as: :regenerate_invoice
      end
      collection do
        get 'invoice_search', as: :invoice_search
      end
    end
    get 'statistics/index'
    resources :shelves
    resources :suppliers
    resources :tax_codes
    resources :templates do
      resources :template_items
    end
    resources :transfers do
      member do
        post 'send_package', as: :send_package
        post 'receive_package', as: :receive_package
      end
    end
    resources :units
    resources :users do
      member do
        patch :update_roles, as: :update_roles
      end
    end
    resources :vats
    resources :verificates do
      resources :verificate_items
      member do
        post 'state_change', as: :state_change
        post 'add_verificate_items', as: :add_verificate_items
      end
    end
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
