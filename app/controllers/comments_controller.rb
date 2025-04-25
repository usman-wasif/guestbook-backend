class CommentsController < ApplicationController
  def index
    comments = Comment.where(is_spam: false).order(created_at: :desc).limit(50)
    render json: comments
  end

  def create
    comment = Comment.new(comment_params)
    comment.is_spam ||= false
    if comment.save
      ActionCable.server.broadcast('comments_channel', comment)
      render json: comment, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:name, :message)
  end
end