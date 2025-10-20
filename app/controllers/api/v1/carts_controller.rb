class Api::V1::CartsController < ApplicationController
  before_action :set_cart, only: [:update, :destroy, :add_item, :remove_item, :get_my_cart, :checkout, :update_item_quantity]

  def index
    carts = Cart.all
    render json: carts
  end

  def show
    cart = Cart.find(params[:id])
    authorize cart
    render json: {cart: cart, total_price: cart.total_price}, status: :ok
  end

  def get_my_cart
    render json: @cart
  end

  def update
    if @cart.update(cart_params)
      render json: @cart
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @cart.destroy
    head :no_content
  end

  def update_item_quantity
    authorize @cart
    item_params = params.require(:cart_item).permit(:product_id, :quantity)
    existing_item = @cart.cart_items.find { |i| i.product_id == item_params[:product_id] }

    if existing_item
      existing_item.quantity = item_params[:quantity].to_i
    else
      begin
        product = Product.find_by(id: item_params[:product_id])
        if product.sold_out?
          render json: { error: "Product sold out" }, status: :unprocessable_entity
          return   
        else
          @cart.cart_items.build(
            product_id: product.id,
            name: product.name,
            price: product.price,
            image: product.image,
            quantity: item_params[:quantity]
          )
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: "Product not found" }, status: :not_found 
        return     
      end
    end

    if @cart.save
      render json: @cart, status: :ok
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def add_item
    authorize @cart
    item_params = params.require(:cart_item).permit(:product_id, :quantity)
    existing_item = @cart.cart_items.find { |i| i.product_id == item_params[:product_id] }

    if existing_item
      existing_item.quantity += item_params[:quantity].to_i
    else
      begin
        product = Product.find_by(id: item_params[:product_id])
        if product.sold_out?
          render json: { error: "Product sold out" }, status: :unprocessable_entity
          return   
        else
          @cart.cart_items.build(
            product_id: product.id,
            name: product.name,
            price: product.price,
            image: product.image,
            quantity: item_params[:quantity]
          )
        end
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: "Product not found" }, status: :not_found 
        return     
      end
    end

    if @cart.save
      render json: @cart, status: :ok
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def remove_item
    product_id = params[:product_id]
    item = @cart.cart_items.find { |i| i.product_id == product_id }

    if item
      @cart.cart_items.delete(item)
      @cart.save
      render json: @cart, status: :ok
    else
      render json: { error: "Item not found" }, status: :not_found
    end
  end

  def checkout
    authorize @cart
    client = OrderClient.new
    response = client.checkout(@cart, params[:promotion_code])

    if response
      @cart.cart_items.destroy
      render json: {
        order_id: response.order_id,
        status: response.status,
        message: response.message
      }, status: :ok
    else
      render json: { error: "Checkout failed" }, status: :bad_gateway
    end
  end

  private

  def set_cart
    # ✅ Find or create cart for current user
    @cart = Cart.find_or_create_by(user_id: current_user[:id])
  end

  def cart_params
    params.require(:cart).permit(:user_id, cart_items_attributes: [:product_id, :name, :image, :price, :quantity])
  end
end
