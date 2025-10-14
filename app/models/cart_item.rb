class CartItem
  include Mongoid::Document

  # Fields
  field :product_id, type: String
  field :name, type: String
  field :image, type: String
  field :price, type: Float
  field :quantity, type: Integer, default: 1

  # Relations
  embedded_in :cart

  # Validations
  validates :product_id, presence: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

end
