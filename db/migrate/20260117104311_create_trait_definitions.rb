class CreateTraitDefinitions < ActiveRecord::Migration[8.1]
  def change
    create_table :trait_definitions do |t|
      t.references :organization, foreign_key: true  # null = system default
      t.references :trait_category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :data_type, null: false  # numeric, scale, select, boolean, text
      t.string :unit
      t.decimal :min_value
      t.decimal :max_value
      t.jsonb :scale_labels, default: {}  # {1: "Poor", 5: "Average", 10: "Excellent"}
      t.string :options, array: true, default: []  # For select type
      t.string :applicable_stages, array: true, default: []  # Which stages this trait applies to
      t.integer :display_order, default: 0
      t.boolean :system_default, default: false

      t.timestamps
    end

    add_index :trait_definitions, :slug
    add_index :trait_definitions, [:trait_category_id, :display_order]
  end
end
