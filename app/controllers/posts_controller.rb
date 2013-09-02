class PostsController < ApplicationController
  def index
    render json: Post.all
  end

  def show
    render json: Post.find(params[:id])
  end

  def create
    render json: Post.create(post_params)
  end

  private

  def post_params
    params.require(:post).permit(
      :title,
      :content,
      :author_id,
      :published_on,
      :status
    )
  end
end
