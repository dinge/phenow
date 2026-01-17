class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.references :parent_comment, foreign_key: { to_table: :comments }
      t.text :body, null: false

      t.timestamps
    end

    add_index :comments, [:commentable_type, :commentable_id]
  end
end
