class CreateStrains < ActiveRecord::Migration[8.1]
  def change
    create_table :strains do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :breeder
      t.string :strain_type
      t.text :description
      t.string :lineage_text
      t.string :genetics_type
      t.integer :flowering_time_min
      t.integer :flowering_time_max
      t.decimal :thc_min, precision: 5, scale: 2
      t.decimal :thc_max, precision: 5, scale: 2
      t.decimal :cbd_min, precision: 5, scale: 2
      t.decimal :cbd_max, precision: 5, scale: 2
      t.string :dominant_terpenes, array: true, default: []
      t.string :effects, array: true, default: []
      t.string :aromas, array: true, default: []
      t.boolean :public, default: false
      t.boolean :verified, default: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :strains, [:organization_id, :slug], unique: true
    add_index :strains, :strain_type
    add_index :strains, :public
  end
end
