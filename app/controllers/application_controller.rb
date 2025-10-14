class ApplicationController < ActionController::API
  before_action :authenticate_user_from_jwt

  private

  # Set current_user from JWT token
  def authenticate_user_from_jwt
    token = request.headers["Authorization"]&.split(" ")&.last

    unless token
      render json: { error: "Token not provided" }, status: :unauthorized
      return
    end

    begin
      # Decode the token using your secret
      payload, _ = JWT.decode(
        token,
        ENV["JWT_SECRET"],
        true,                  # verify signature
        algorithm: "HS256"     # your JWT algorithm
      )

      @current_user = User.find(payload["sub"])
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
