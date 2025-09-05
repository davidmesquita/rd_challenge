require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
  resource :cart, only: [:show] do
    post '/', to: 'carts#add_new_item'                  # adiciona produto
    post 'add_item', to: 'carts#update_item_quantity'  # altera quantidade existente
    delete ':product_id', to: 'carts#remove_item'      # decrementa 1 unidade
    delete ':product_id/remove_all', to: 'carts#remove_all' # remove todas
  end

end
