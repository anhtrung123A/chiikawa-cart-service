class CartPolicy
  attr_reader :user, :cart

  def initialize(user, cart)
    @user = user
    @cart = cart
  end

  def create?
    user.role == "admin"
  end

  def add_item?
    user[:id] == cart.user_id
  end

  def remove_item?
    user[:id] == cart.user_id
  end

  def index?
    user[:role] == "admin"
  end

  def show?
    user[:id] == cart.user_id || user[:role] == "admin"
  end
end
