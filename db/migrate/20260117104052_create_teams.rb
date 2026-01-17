class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :teams, [:organization_id, :slug], unique: true
  end
end
