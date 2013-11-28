class PostSearch
  attr_accessor :page, :per_page, :filters

  def initialize(params)
    @page = params[:page] || 1
    @per_page = params[:per_page] || 5
    @filters = params[:filters] || {}
  end

  def search
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