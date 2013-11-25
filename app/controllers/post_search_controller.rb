class PostSearchController < ApplicationController

  def index
    @post_search = PostSearch.new(params).post_search

    render json: @post_search
  end
end