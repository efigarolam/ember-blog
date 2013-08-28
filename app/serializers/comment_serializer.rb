class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :status, :created_at
end
