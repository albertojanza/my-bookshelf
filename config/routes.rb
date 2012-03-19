MyBookshelf::Application.routes.draw do

  resources :contacts

  resources :comments

  get 'assure_destroy' => 'experiences#assure_destroy', :as => :assure_experience_destroy
  resources :experiences
  get 'recommend_books' => 'experiences#recommend', :as => :book_recommend
  post 'create_recommendations' => 'experiences#create_recommendations', :as => :create_recommendations

  resources :reviews

  get "/friends_bookcase" => 'books#friends_bookcase', :as => 'friends_bookcase'
  get "/bookcase" => 'books#bookcase', :as => 'bookcase'
  get "/shelf" => 'books#shelf', :as => 'shelf'
  #get "/bookcase/read_books" => 'books#bookcase_read_books', :as => 'read_books'
  #get "/bookcase/recommended_books" => 'books#bookcase_recommended_books', :as => 'recommended_books'
  #get "/bookcase/next_books" => 'books#bookcase_next_books', :as => 'next_books'
  #get "/bookcase/reading_books" => 'books#bookcase_reading_books', :as => 'reading_books'

  get "/libroshefl_rate" => 'users#influence_rate', :as => 'influence_rate'
  get "/account" => 'users#account', :as => 'account'
  post 'communication_form' => 'users#communication_form'
  post 'libroshelf_communication_form' => 'users#libroshelf_communication_form'

  resources :books
  get 'book_show_friends' => 'books#show_friends', :as => :book_show_friends
  get 'book_asin' => 'books#show', :as => :book_asin
  post 'books/search' => 'books#search', :as => :search
  get 'book_similarities' => 'books#sidebar_similarities', :as => :book_similarities

  get 'facebook_dialog_response' => 'facebook#dialog_response', :as => :facebook_dialog_response
  get 'facebook_dialog' => 'facebook#send_dialog', :as => :facebook_dialog
  get 'friends' => 'facebook#friend_list', :as => :friends
  get "facebook/callback" => 'sessions#facebook_callback', :as => 'facebook_callback'
  get "canvas/callback" => 'sessions#canvas_callback', :as => 'canvas_callback'

  get "facebook/permission" => 'sessions#facebook_permission', :as => 'facebook_permission'
  
  get '/logout' => 'sessions#destroy', :as => :logout

  get 'welcome/fake' => 'welcome#fake', :as => :fake
  get 'welcome/timeline' => 'welcome#timeline', :as => :timeline
  post 'canvas' => 'welcome#canvas', :as => :canvas


  get 'welcome/privacy' => 'welcome#privacy', :as => :privacy

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
   root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
