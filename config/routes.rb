Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :carts
      post "/cart/items", to: "carts#add_item"
      delete "/cart/items", to: "carts#remove_item"
      delete "/cart/my_cart", to: "carts#get_my_cart"
      post "/cart/checkout", to: "carts#checkout"
    end
  end
end
