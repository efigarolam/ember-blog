class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_name, :email, :admin, :active
  embed :ids, include: true

  has_many :comments, key: :comments, root: :comments
end
