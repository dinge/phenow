class CreatePlants < ActiveRecord::Migration[8.1]
  def change
    create_table :plants do |t|
      t.references :project, null: false, foreign_key: true
      t.references :strain, foreign_key: true
      t.string :identifier, null: false
      t.string :name
      t.string :source_type, null: false, default: "seed"
      t.references :source_plant, foreign_key: { to_table: :plants }
      t.string :sex, default: "unknown"
      t.string :current_stage, default: "germination"
      t.string :status, default: "active"
      t.date :germination_date
      t.date :flip_date
      t.date :harvest_date
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :plants, [:project_id, :identifier], unique: true
    add_index :plants, [:project_id, :status]
    add_index :plants, [:project_id, :current_stage]
  end
end
