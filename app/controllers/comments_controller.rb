class CommentsController < ApplicationController
  def index
    comments = Comment.recent_non_spam
    render json: comments
  end

  def create
    comment = Comment.new(comment_params)
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