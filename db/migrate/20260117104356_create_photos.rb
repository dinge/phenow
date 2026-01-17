class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :photographable, polymorphic: true, null: false
      t.references :taken_by, foreign_key: { to_table: :users }
      t.datetime :taken_at
      t.text :caption
      t.string :photo_type  # whole_plant, bud, trichome, leaf, environment
      t.string :stage
      t.boolean :is_primary, default: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :photos, [:photographable_type, :photographable_id]
  end
end
