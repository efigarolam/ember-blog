EmberBlog::Application.routes.draw do
  root to: 'blog#init'

  resources :users, defaults: {format: :json} do
    resources :comments, defaults: {format: :json}, only: [:index]
  end

  resources :posts, defaults: {format: :json} do
    resources :comments, defaults: {format: :json}
  end
end
