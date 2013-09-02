class CurrentUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_name, :email, :admin, :active
end