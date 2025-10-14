class Api::V1::CartsController < ApplicationController
  before_action :set_cart, only: [:show, :update, :destroy, :add_item, :remove_item]

  # GET /api/v1/carts
  def index
    carts = Cart.all
    render json: carts
  end

  # GET /api/v1/carts/:id
  def show
    render json: @cart
  end

  # POST /api/v1/carts
  def create
    cart = Cart.new(cart_params)
    if cart.save
      render json: cart, status: :created
    else
      render json: { errors: cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/carts/:id
  def update
    if @cart.update(cart_params)
      render json: @cart
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/carts/:id
  def destroy
    @cart.destroy
    head :no_content
  end

  # POST /api/v1/carts/:id/add_item
  def add_item
    item_params = params.require(:cart_item).permit(:product_id, :name, :image, :price, :quantity)
    existing_item = @cart.cart_items.find { |i| i.product_id == item_params[:product_id] }

    if existing_item
      existing_item.quantity += item_params[:quantity].to_i
    else
      @cart.cart_items.build(item_params)
    end

    if @cart.save
      render json: @cart, status: :ok
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/carts/:id/remove_item
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

  private

  def set_cart
    @cart = Cart.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { error: "Cart not found" }, status: :not_found
  end

  def cart_params
    params.require(:cart).permit(:user_id, cart_items_attributes: [:product_id, :name, :image, :price, :quantity])
  end
end
