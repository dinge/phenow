class CreateStrainLineages < ActiveRecord::Migration[8.1]
  def change
    create_table :strain_lineages do |t|
      t.references :child_strain, null: false, foreign_key: { to_table: :strains }
      t.references :parent_strain, null: false, foreign_key: { to_table: :strains }
      t.string :parent_role, null: false

      t.timestamps
    end

    add_index :strain_lineages, [:child_strain_id, :parent_strain_id], unique: true
  end
end
