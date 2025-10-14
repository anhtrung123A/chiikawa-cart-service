class Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: Integer
  embeds_many :cart_items, cascade_callbacks: true

  index({ user_id: 1 })

  accepts_nested_attributes_for :cart_items, allow_destroy: true

  validates :user_id, presence: true

  def total_price
    cart_items.sum { |item| item.price.to_f * item.quantity.to_i }
  end
end
