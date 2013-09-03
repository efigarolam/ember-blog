class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :published_on, :status
  embed :ids, include: true

  has_one :author, key: :author, root: :users
  has_many :comments, key: :comments, root: :comments
end
