class CreateProjectGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :project_goals do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :priority, default: 0
      t.references :target_trait, foreign_key: { to_table: :trait_definitions }
      t.string :target_value
      t.boolean :achieved, default: false

      t.timestamps
    end

    add_index :project_goals, [:project_id, :priority]
  end
end
