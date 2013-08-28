class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :author_id
      t.string :title
      t.text :content
      t.string :status
      t.date :published_on

      t.timestamps
    end
  end
end
