class Product
  include Mongoid::Document
  store_in collection: "products"

  field :name, type: String
  field :image, type: String
  field :price, type: Float
  field :status, type: String
  
  STATUSES = %w[available sold_out discontinued]

  def available!
    update(status: "available")
  end

  def sold_out!
    update(status: "sold_out")
  end

  def discontinued!
    update(status: "discontinued")
  end

  def available?
    status == "available"
  end

  def sold_out?
    status == "sold_out"
  end

  def discontinued?
    status == "discontinued"
  end
end
