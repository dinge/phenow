class CreateSelections < ActiveRecord::Migration[8.1]
  def change
    create_table :selections do |t|
      t.references :plant, null: false, foreign_key: true
      t.references :selected_by, null: false, foreign_key: { to_table: :users }
      t.string :decision, null: false  # keep, cull, breeding_mother, breeding_father, further_evaluation
      t.datetime :selected_at, null: false
      t.text :reasoning, null: false
      t.decimal :score, precision: 3, scale: 1  # 1-10
      t.string :standout_traits, array: true, default: []
      t.string :concerns, array: true, default: []

      t.timestamps
    end

    add_index :selections, [:plant_id, :decision]
  end
end
