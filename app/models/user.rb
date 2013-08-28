class User < ActiveRecord::Base
  has_many :posts, foreign_key: :author_id
  has_many :comments

  validates_presence_of :name, :last_name, :email
end