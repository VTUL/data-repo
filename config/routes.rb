Rails.application.routes.draw do
  get 'osf_api/detail/:project_id', to: 'osf_api#detail'

  get 'osf_api/list', :as => :api_list

  get 'osf_auth/index'

  get 'osf_auth/auth', :as => :oauth_auth

  get 'osf_auth/callback'

  get 'osf_auth/token'

  get 'collections/datacite_search', to: 'collections#datacite_search'
  post 'collections/crossref_search', to: 'collections#crossref_search'
  get "collections/import_metadata", to: 'collections#import_metadata', as: 'import_collection'
  get 'collections/ldap_search', to: 'collections#ldap_search'
  get 'dashboard/publishables', to: 'publishables#index', as: 'dashboard_publishables'
  get 'help', to: 'contact_form#new', as: 'help_page'
  get 'policies', to: 'pages#show', id: 'policies_page', as: 'policies'
  get 'user_guides', to: 'pages#show', id: 'user_guides_page', as: 'user_guides'
  get 'collections/:id/add-files', to: 'collections#add_files', as: 'collections_add_files'
  get 'collections/:id/dataset-download(/:admin)', to: 'collections#dataset_download', as: 'collections_download'
  get 'dashboard/admin_metadata_download', to: 'dashboard#admin_metadata_download', as: 'admin_metadata_download'
  
  get 'users/depositors', to: 'users#depositor_list_export', as: 'depositor_list'

  blacklight_for :catalog

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  get 'users/auth/cas', to: 'users/omniauth_callbacks#passthru', as: 'new_user_session'
  devise_scope :user do
    get 'sign_in', to: redirect('/users/auth/cas')
    get 'sign_out', to: 'devise/sessions#destroy', as: 'destroy_user_session'
  end

  mount Orcid::Engine => "/orcid"

  mount Hydra::RoleManagement::Engine => '/'

  resources :doi_requests, :only => [:index, :create] do
    member do
      patch 'mint_doi'
      get 'view_doi'
    end

    collection do
      get 'pending'
      patch 'mint_all'
    end
  end

  Hydra::BatchEdit.add_routes(self)

  # This must be the very last route in the file because it has a catch-all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
  root to: 'homepage#index'

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
