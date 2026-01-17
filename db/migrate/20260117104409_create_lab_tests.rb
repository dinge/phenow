class CreateLabTests < ActiveRecord::Migration[8.1]
  def change
    create_table :lab_tests do |t|
      t.references :plant, null: false, foreign_key: true
      t.string :lab_name
      t.date :test_date
      t.string :sample_type  # flower, concentrate, edible
      t.string :batch_number
      t.string :coa_url
      t.decimal :total_thc, precision: 5, scale: 2
      t.decimal :total_cbd, precision: 5, scale: 2
      t.decimal :total_cannabinoids, precision: 5, scale: 2
      t.decimal :total_terpenes, precision: 5, scale: 2
      t.jsonb :cannabinoid_profile, default: {}  # {thca: 22.5, thc: 0.8, ...}
      t.jsonb :terpene_profile, default: {}  # {myrcene: 1.2, limonene: 0.8, ...}
      t.jsonb :contaminants, default: {}
      t.boolean :passed
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :lab_tests, [:plant_id, :test_date]
  end
end
