class CreatePlantStageTransitions < ActiveRecord::Migration[8.1]
  def change
    create_table :plant_stage_transitions do |t|
      t.references :plant, null: false, foreign_key: true
      t.string :from_stage
      t.string :to_stage, null: false
      t.datetime :transitioned_at, null: false
      t.text :notes
      t.references :recorded_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :plant_stage_transitions, [:plant_id, :transitioned_at]
  end
end
