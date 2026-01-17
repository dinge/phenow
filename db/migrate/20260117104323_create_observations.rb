class CreateObservations < ActiveRecord::Migration[8.1]
  def change
    create_table :observations do |t|
      t.references :plant, null: false, foreign_key: true
      t.references :observed_by, null: false, foreign_key: { to_table: :users }
      t.datetime :observed_at, null: false
      t.string :stage
      t.integer :week_number
      t.decimal :overall_score, precision: 3, scale: 1  # 1-10
      t.text :notes

      t.timestamps
    end

    add_index :observations, [:plant_id, :observed_at]
  end
end
