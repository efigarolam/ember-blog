class Post < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  has_many :comments

  validates_presence_of :title, :content, :author
end