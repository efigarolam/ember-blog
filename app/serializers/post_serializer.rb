class PostSerializer < ActiveModel::Serializer
  attributes :id, :author_id, :title, :content, :published_on, :status
  embed :ids, include: true

  has_one :author, key: :author_id, root: :users
  has_many :comments, key: :comment_ids, root: :comments
end
