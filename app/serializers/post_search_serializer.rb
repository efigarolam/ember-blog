class PostSearchSerializer
  attr_accessor :search
  delegate :current_page, :per_page, :total_entries, :total_pages, to: :pagination_info

  def initialize(params)
    @search = PostSearch.new(params).search
  end

  def serialize
    {
      post_search:
      [
        {
          id: current_page,
          page: current_page,
          per_page: per_page,
          total_entries: total_entries,
          total_pages: total_pages,
          post_ids: post_ids
        }
      ],
      posts: search_results
    }
  end

  private

  def post_ids
    search_results.map(&:id)
  end

  def search_results
    search.results
  end

  def pagination_info
    search.hits
  end
end