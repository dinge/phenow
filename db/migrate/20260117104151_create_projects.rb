class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :team, null: false, foreign_key: true
      t.references :strain, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :project_type, null: false, default: "phenohunt"
      t.string :status, null: false, default: "active"
      t.text :description
      t.date :start_date
      t.date :target_end_date
      t.date :actual_end_date
      t.integer :seed_count
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :projects, [:team_id, :slug], unique: true
    add_index :projects, :status
    add_index :projects, :project_type
  end
end
