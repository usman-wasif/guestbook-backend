module AdminPanel
  class CommentsController < ApplicationController
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    
    before_action :authenticate_admin

    def index
      comments = Comment.all.order(created_at: :desc)
      render json: comments
    end

    def mark_spam
      comment = Comment.find(params[:id])
      comment.update(is_spam: true)
      render json: comment
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Comment not found' }, status: :not_found
    end

    def destroy
      comment = Comment.find(params[:id])
      comment.destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Comment not found' }, status: :not_found
    end

    private

    def authenticate_admin
      authenticate_or_request_with_http_basic do |username, password|
        admin = Admin.find_by(username: username)
        admin&.authenticate(password)
      end
    end
  end
end