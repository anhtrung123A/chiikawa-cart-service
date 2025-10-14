class ApplicationController < ActionController::API
  before_action :authenticate_user_from_jwt
  include Pundit::Authorization

  private

  def authenticate_user_from_jwt
    token = request.headers["Authorization"]&.split(" ")&.last
    return render json: { error: "Token not provided" }, status: :unauthorized unless token

    begin
      payload, _ = JWT.decode(token, ENV["JWT_SECRET"], true, algorithm: "HS256")

      if payload["exp"] && Time.at(payload["exp"]) < Time.now
        return render json: { error: "Token expired" }, status: :unauthorized
      end

      @current_user = {
        id: payload["sub"].to_i,
        email: payload["email"],
        full_name: payload["full_name"],
        role: payload["role"]
      }.compact
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end
end
