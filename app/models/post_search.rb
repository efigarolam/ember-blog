class PostSearch
  # include ActiveModel::Serializers::JSON
  attr_accessor :posts, :post_ids, :filters, :page, :per_page

  def initialize(attrs)
    @page = attrs[:page] || 1
    @per_page = attrs[:per_page] || 10
    @filters = attrs[:filters] || {}
  end

  def results
    @results ||= search.results
  end

  def pagination_info
    @results_info ||= search.hits
  end

  def post_search
    {
      meta:
      [
        {
          page: current_page,
          total_pages: total_pages,
          per_page: per_page,
          post_ids: post_ids
        }
      ],
      posts: serialized_posts
    }
  end

  private

  def post_ids
    @post_ids ||= results.map(&:id)
  end

  def serialized_posts
    @posts ||= results.collect do |post|
      PostSerializer.new post
    end
  end

  def search
    @search ||= begin
      Post.search do
        paginate page: page, per_page: per_page
        keywords(filters[:search]) if filters[:search].present?
        with(:id, filters[:id]) if filters[:id].present?
        with(:author_id, filters[:author_id]) if filters[:author_id].present?

        if filters[:published_on_from].present? || filters[:published_on_to].present?
          all_of do
            with(:published_on).between(filters[:published_on_from].to_date..filters[:published_on_to].to_date) if filters[:published_on_from].present? && filters[:published_on_to].present?
            with(:published_on).greater_than(filters[:published_on_from].to_date - 1.day) if filters[:published_on_from].present?
            with(:published_on).less_than(filters[:published_on_to].to_date + 1.day) if filters[:published_on_to].present?
          end
        end

        if filters[:order_by].present?
          order_by(filters[:order_by], filters[:order_direction] || 'desc')
        else
          order_by(:id, 'desc')
        end
      end
    end
  end

  def method_missing method, *args
    if pagination_info.respond_to? method
      pagination_info.send method, *args
    else
      super method, *args
    end
  end
end