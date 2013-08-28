class CommentsController < ApplicationController
  def index
    render json: Post.find(params[:post_id]).comments
  end

  def show
    render json: Comment.find(params[:id])
  end
end
