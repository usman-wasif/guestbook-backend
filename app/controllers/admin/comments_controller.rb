require 'jwt'

module Admin
  class CommentsController < ApplicationController
    
    before_action :authenticate_admin, except: %i[login]
    before_action :get_comment, only: %i[mark_spam destroy]

    def index
      comments = Comment.all.order(created_at: :desc)
      render json: comments
    end

    def mark_spam
      @comment.update(is_spam: true)
      render json: @comment
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Comment not found' }, status: :not_found
    end

    def destroy
      @comment.destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Comment not found' }, status: :not_found
    end

    def login
      admin = AdminUser.find_by(username: params[:username])
      if admin&.authenticate(params[:password])
        token = generate_jwt(admin)
        session[:admin_user_id] = admin.id
        render json: { message: 'Logged in successfully', token: token }, status: :ok
      else
        render json: { error: 'Invalid username or password' }, status: :unauthorized
      end
    end

    def logout
      session[:admin_user_id] = nil
      render json: { message: 'Logged out successfully' }, status: :ok
    end

    private

    def authenticate_admin
      if request.headers['Authorization'].present?
        token = request.headers['Authorization'].split('Bearer ').last
        begin
          decoded = decode_jwt(token)
          @current_admin = AdminUser.find(decoded['admin_id'])
          return if @current_admin
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
          return
        end
      end

      unless current_admin
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    def current_admin
      @current_admin ||= AdminUser.find_by(id: session[:admin_user_id])
    end

    def generate_jwt(admin)
      payload = { admin_id: admin.id, exp: 24.hours.from_now.to_i }
      JWT.encode(payload, ENV['JWT_SECRET'], 'HS256')
    end

    def decode_jwt(token)
      JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256').first
    end

    def get_comment
      @comment = Comment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Comment not found' }, status: :not_found
      nil
    end
  end
end