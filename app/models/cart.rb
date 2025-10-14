class Cart
  include Mongoid::Document
  include Mongoid::Timestamps
  # Fields
  field :user_id, type: Integer
  embeds_many :cart_items

  index({ user_id: 1 })
  
  def total_price
    cart_items.sum { |item| item.price.to_f * item.quantity.to_i }
  end
end
