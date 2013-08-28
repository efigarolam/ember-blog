class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :user_id
      t.string :post_id
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
