require "grpc"
require "order"

class OrderClient
  def initialize
    @stub = Order::OrderService::Stub.new(
      ENV.fetch("ORDER_SERVICE_URL", "localhost:50051"),
      :this_channel_is_insecure
    )
  end

  def checkout(cart, promotion_code, delivery_address)
     address = if delivery_address.is_a?(Hash)
                Order::DeliveryAddress.new(delivery_address.symbolize_keys)
               else
                delivery_address
               end
    items = cart.cart_items.map do |item|
      Order::CartItem.new(
        product_id: item.product_id,
        name: item.name,
        image: item.image,
        price: item.price,
        quantity: item.quantity
      )
    end

    request = Order::CheckoutRequest.new(
      user_id: cart.user_id,
      items: items,
      promotion_code: promotion_code,
      delivery_address: address
    )

    @stub.checkout(request)
  rescue GRPC::BadStatus => e
    Rails.logger.error "gRPC checkout failed: #{e.message}"
    nil
  end
end
