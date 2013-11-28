class Post < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  has_many :comments

  validates_presence_of :title, :content, :author

  searchable do
    text :title, :content, :status

    integer :id
    integer :author_id
    time    :published_on
  end
end