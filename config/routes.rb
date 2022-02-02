Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  scope module: 'api' do
    get :ping, path: 'api/ping', defaults: { format: 'json' }
    get :posts, path: 'api/posts', defaults: { format: 'json' }
  end
end
