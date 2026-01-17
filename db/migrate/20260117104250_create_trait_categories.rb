class CreateTraitCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :trait_categories do |t|
      t.references :organization, foreign_key: true  # null = system default
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :display_order, default: 0
      t.string :icon

      t.timestamps
    end

    add_index :trait_categories, :slug
  end
end
