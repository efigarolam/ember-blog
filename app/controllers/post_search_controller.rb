class PostSearchController < ApplicationController

  def index
    @post_search = PostSearchSerializer.new(params).serialize

    render json: @post_search
  end
end