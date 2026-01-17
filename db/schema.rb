# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_17_105025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "commentable_id", null: false
    t.string "commentable_type", null: false
    t.datetime "created_at", null: false
    t.bigint "parent_comment_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["parent_comment_id"], name: "index_comments_on_parent_comment_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "lab_tests", force: :cascade do |t|
    t.string "batch_number"
    t.jsonb "cannabinoid_profile", default: {}
    t.string "coa_url"
    t.jsonb "contaminants", default: {}
    t.datetime "created_at", null: false
    t.string "lab_name"
    t.jsonb "metadata", default: {}
    t.text "notes"
    t.boolean "passed"
    t.bigint "plant_id", null: false
    t.string "sample_type"
    t.jsonb "terpene_profile", default: {}
    t.date "test_date"
    t.decimal "total_cannabinoids", precision: 5, scale: 2
    t.decimal "total_cbd", precision: 5, scale: 2
    t.decimal "total_terpenes", precision: 5, scale: 2
    t.decimal "total_thc", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.index ["plant_id", "test_date"], name: "index_lab_tests_on_plant_id_and_test_date"
    t.index ["plant_id"], name: "index_lab_tests_on_plant_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role", default: "member", null: false
    t.bigint "team_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["user_id", "team_id"], name: "index_memberships_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "observations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.datetime "observed_at", null: false
    t.bigint "observed_by_id", null: false
    t.decimal "overall_score", precision: 3, scale: 1
    t.bigint "plant_id", null: false
    t.string "stage"
    t.datetime "updated_at", null: false
    t.integer "week_number"
    t.index ["observed_by_id"], name: "index_observations_on_observed_by_id"
    t.index ["plant_id", "observed_at"], name: "index_observations_on_plant_id_and_observed_at"
    t.index ["plant_id"], name: "index_observations_on_plant_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "server_url"
    t.jsonb "settings", default: {}
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "photos", force: :cascade do |t|
    t.text "caption"
    t.datetime "created_at", null: false
    t.boolean "is_primary", default: false
    t.jsonb "metadata", default: {}
    t.string "photo_type"
    t.bigint "photographable_id", null: false
    t.string "photographable_type", null: false
    t.string "stage"
    t.datetime "taken_at"
    t.bigint "taken_by_id"
    t.datetime "updated_at", null: false
    t.index ["photographable_type", "photographable_id"], name: "index_photos_on_photographable"
    t.index ["photographable_type", "photographable_id"], name: "index_photos_on_photographable_type_and_photographable_id"
    t.index ["taken_by_id"], name: "index_photos_on_taken_by_id"
  end

  create_table "plant_stage_transitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "from_stage"
    t.text "notes"
    t.bigint "plant_id", null: false
    t.bigint "recorded_by_id"
    t.string "to_stage", null: false
    t.datetime "transitioned_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id", "transitioned_at"], name: "index_plant_stage_transitions_on_plant_id_and_transitioned_at"
    t.index ["plant_id"], name: "index_plant_stage_transitions_on_plant_id"
    t.index ["recorded_by_id"], name: "index_plant_stage_transitions_on_recorded_by_id"
  end

  create_table "plants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "current_stage", default: "germination"
    t.date "flip_date"
    t.date "germination_date"
    t.date "harvest_date"
    t.string "identifier", null: false
    t.jsonb "metadata", default: {}
    t.string "name"
    t.text "notes"
    t.bigint "project_id", null: false
    t.string "sex", default: "unknown"
    t.bigint "source_plant_id"
    t.string "source_type", default: "seed", null: false
    t.string "status", default: "active"
    t.bigint "strain_id"
    t.datetime "updated_at", null: false
    t.index ["project_id", "current_stage"], name: "index_plants_on_project_id_and_current_stage"
    t.index ["project_id", "identifier"], name: "index_plants_on_project_id_and_identifier", unique: true
    t.index ["project_id", "status"], name: "index_plants_on_project_id_and_status"
    t.index ["project_id"], name: "index_plants_on_project_id"
    t.index ["source_plant_id"], name: "index_plants_on_source_plant_id"
    t.index ["strain_id"], name: "index_plants_on_strain_id"
  end

  create_table "project_goals", force: :cascade do |t|
    t.boolean "achieved", default: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "priority", default: 0
    t.bigint "project_id", null: false
    t.bigint "target_trait_id"
    t.string "target_value"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "priority"], name: "index_project_goals_on_project_id_and_priority"
    t.index ["project_id"], name: "index_project_goals_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.date "actual_end_date"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "project_type", default: "phenohunt", null: false
    t.integer "seed_count"
    t.jsonb "settings", default: {}
    t.string "slug", null: false
    t.date "start_date"
    t.string "status", default: "active", null: false
    t.bigint "strain_id"
    t.date "target_end_date"
    t.bigint "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_type"], name: "index_projects_on_project_type"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["strain_id"], name: "index_projects_on_strain_id"
    t.index ["team_id", "slug"], name: "index_projects_on_team_id_and_slug", unique: true
    t.index ["team_id"], name: "index_projects_on_team_id"
  end

  create_table "selections", force: :cascade do |t|
    t.string "concerns", default: [], array: true
    t.datetime "created_at", null: false
    t.string "decision", null: false
    t.bigint "plant_id", null: false
    t.text "reasoning", null: false
    t.decimal "score", precision: 3, scale: 1
    t.datetime "selected_at", null: false
    t.bigint "selected_by_id", null: false
    t.string "standout_traits", default: [], array: true
    t.datetime "updated_at", null: false
    t.index ["plant_id", "decision"], name: "index_selections_on_plant_id_and_decision"
    t.index ["plant_id"], name: "index_selections_on_plant_id"
    t.index ["selected_by_id"], name: "index_selections_on_selected_by_id"
  end

  create_table "strain_lineages", force: :cascade do |t|
    t.bigint "child_strain_id", null: false
    t.datetime "created_at", null: false
    t.string "parent_role", null: false
    t.bigint "parent_strain_id", null: false
    t.datetime "updated_at", null: false
    t.index ["child_strain_id", "parent_strain_id"], name: "index_strain_lineages_on_child_strain_id_and_parent_strain_id", unique: true
    t.index ["child_strain_id"], name: "index_strain_lineages_on_child_strain_id"
    t.index ["parent_strain_id"], name: "index_strain_lineages_on_parent_strain_id"
  end

  create_table "strains", force: :cascade do |t|
    t.string "aromas", default: [], array: true
    t.string "breeder"
    t.decimal "cbd_max", precision: 5, scale: 2
    t.decimal "cbd_min", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.string "dominant_terpenes", default: [], array: true
    t.string "effects", default: [], array: true
    t.integer "flowering_time_max"
    t.integer "flowering_time_min"
    t.string "genetics_type"
    t.string "lineage_text"
    t.jsonb "metadata", default: {}
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.boolean "public", default: false
    t.string "slug", null: false
    t.string "strain_type"
    t.decimal "thc_max", precision: 5, scale: 2
    t.decimal "thc_min", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.index ["organization_id", "slug"], name: "index_strains_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_strains_on_organization_id"
    t.index ["public"], name: "index_strains_on_public"
    t.index ["strain_type"], name: "index_strains_on_strain_type"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_taggings_on_tag_id_and_taggable_type_and_taggable_id", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "slug"], name: "index_tags_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_tags_on_organization_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.jsonb "settings", default: {}
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "slug"], name: "index_teams_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_teams_on_organization_id"
  end

  create_table "trait_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "display_order", default: 0
    t.string "icon"
    t.string "name", null: false
    t.bigint "organization_id"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_trait_categories_on_organization_id"
    t.index ["slug"], name: "index_trait_categories_on_slug"
  end

  create_table "trait_definitions", force: :cascade do |t|
    t.string "applicable_stages", default: [], array: true
    t.datetime "created_at", null: false
    t.string "data_type", null: false
    t.text "description"
    t.integer "display_order", default: 0
    t.decimal "max_value"
    t.decimal "min_value"
    t.string "name", null: false
    t.string "options", default: [], array: true
    t.bigint "organization_id"
    t.jsonb "scale_labels", default: {}
    t.string "slug", null: false
    t.boolean "system_default", default: false
    t.bigint "trait_category_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_trait_definitions_on_organization_id"
    t.index ["slug"], name: "index_trait_definitions_on_slug"
    t.index ["trait_category_id", "display_order"], name: "index_trait_definitions_on_trait_category_id_and_display_order"
    t.index ["trait_category_id"], name: "index_trait_definitions_on_trait_category_id"
  end

  create_table "trait_values", force: :cascade do |t|
    t.boolean "boolean_value"
    t.datetime "created_at", null: false
    t.text "notes"
    t.decimal "numeric_value"
    t.bigint "observation_id", null: false
    t.string "text_value"
    t.bigint "trait_definition_id", null: false
    t.datetime "updated_at", null: false
    t.index ["observation_id", "trait_definition_id"], name: "index_trait_values_on_observation_id_and_trait_definition_id", unique: true
    t.index ["observation_id"], name: "index_trait_values_on_observation_id"
    t.index ["trait_definition_id"], name: "index_trait_values_on_trait_definition_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.jsonb "preferences", default: {}
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "timezone", default: "UTC"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "comments", column: "parent_comment_id"
  add_foreign_key "comments", "users"
  add_foreign_key "lab_tests", "plants"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "observations", "plants"
  add_foreign_key "observations", "users", column: "observed_by_id"
  add_foreign_key "photos", "users", column: "taken_by_id"
  add_foreign_key "plant_stage_transitions", "plants"
  add_foreign_key "plant_stage_transitions", "users", column: "recorded_by_id"
  add_foreign_key "plants", "plants", column: "source_plant_id"
  add_foreign_key "plants", "projects"
  add_foreign_key "plants", "strains"
  add_foreign_key "project_goals", "projects"
  add_foreign_key "projects", "strains"
  add_foreign_key "projects", "teams"
  add_foreign_key "selections", "plants"
  add_foreign_key "selections", "users", column: "selected_by_id"
  add_foreign_key "strain_lineages", "strains", column: "child_strain_id"
  add_foreign_key "strain_lineages", "strains", column: "parent_strain_id"
  add_foreign_key "strains", "organizations"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tags", "organizations"
  add_foreign_key "teams", "organizations"
  add_foreign_key "trait_categories", "organizations"
  add_foreign_key "trait_definitions", "organizations"
  add_foreign_key "trait_definitions", "trait_categories"
  add_foreign_key "trait_values", "observations"
  add_foreign_key "trait_values", "trait_definitions"
end
