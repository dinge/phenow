class CreateTraitValues < ActiveRecord::Migration[8.1]
  def change
    create_table :trait_values do |t|
      t.references :observation, null: false, foreign_key: true
      t.references :trait_definition, null: false, foreign_key: true
      t.decimal :numeric_value
      t.string :text_value
      t.boolean :boolean_value
      t.text :notes

      t.timestamps
    end

    add_index :trait_values, [:observation_id, :trait_definition_id], unique: true
  end
end
