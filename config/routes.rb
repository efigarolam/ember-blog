EmberBlog::Application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  root to: 'blog#init'

  resources :users, defaults: {format: :json} do
    resources :comments, defaults: {format: :json}, only: [:index]
  end

  resources :posts, defaults: {format: :json} do
    resources :comments, defaults: {format: :json}
  end

  resources :post_search, defaults: {format: :json}
end
