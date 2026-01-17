# frozen_string_literal: true

# Default Trait Categories and Definitions for Phenohunting
# These are system defaults (organization_id: nil) available to all organizations

puts "Seeding default trait categories and definitions..."

# Helper to create trait definitions
def create_trait(category, attrs)
  TraitDefinition.find_or_create_by!(
    trait_category: category,
    name: attrs[:name],
    organization_id: nil
  ) do |t|
    t.slug = attrs[:name].parameterize
    t.description = attrs[:description]
    t.data_type = attrs[:data_type]
    t.unit = attrs[:unit]
    t.min_value = attrs[:min_value]
    t.max_value = attrs[:max_value]
    t.scale_labels = attrs[:scale_labels] || {}
    t.options = attrs[:options] || []
    t.applicable_stages = attrs[:applicable_stages] || []
    t.display_order = attrs[:display_order] || 0
    t.system_default = true
  end
end

# Vigor & Health Category
vigor = TraitCategory.find_or_create_by!(name: "Vigor & Health", organization_id: nil) do |c|
  c.slug = "vigor-health"
  c.description = "Overall plant health and growth characteristics"
  c.display_order = 1
  c.icon = "heart"
end

create_trait(vigor, {
  name: "Overall Vigor",
  description: "General health and growth rate",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Poor", "5" => "Average", "10" => "Excellent" },
  applicable_stages: %w[seedling vegetative flowering],
  display_order: 1
})

create_trait(vigor, {
  name: "Growth Speed",
  description: "How fast the plant is growing",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Slow", "5" => "Average", "10" => "Very Fast" },
  applicable_stages: %w[seedling vegetative],
  display_order: 2
})

create_trait(vigor, {
  name: "Pest Resistance",
  description: "Resistance to common pests",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Susceptible", "5" => "Average", "10" => "Highly Resistant" },
  applicable_stages: %w[vegetative flowering],
  display_order: 3
})

create_trait(vigor, {
  name: "Disease Resistance",
  description: "Resistance to mold, mildew, and other diseases",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Susceptible", "5" => "Average", "10" => "Highly Resistant" },
  applicable_stages: %w[vegetative flowering],
  display_order: 4
})

# Structure Category
structure = TraitCategory.find_or_create_by!(name: "Structure", organization_id: nil) do |c|
  c.slug = "structure"
  c.description = "Plant architecture and physical characteristics"
  c.display_order = 2
  c.icon = "tree"
end

create_trait(structure, {
  name: "Height",
  description: "Plant height measurement",
  data_type: "numeric",
  unit: "cm",
  min_value: 0,
  max_value: 500,
  applicable_stages: %w[vegetative pre_flower flowering],
  display_order: 1
})

create_trait(structure, {
  name: "Spread",
  description: "Plant width/canopy spread",
  data_type: "numeric",
  unit: "cm",
  min_value: 0,
  max_value: 300,
  applicable_stages: %w[vegetative flowering],
  display_order: 2
})

create_trait(structure, {
  name: "Internode Spacing",
  description: "Distance between branch nodes",
  data_type: "select",
  options: %w[tight medium stretchy],
  applicable_stages: %w[vegetative],
  display_order: 3
})

create_trait(structure, {
  name: "Branching Pattern",
  description: "How the plant branches",
  data_type: "select",
  options: %w[minimal moderate heavy],
  applicable_stages: %w[vegetative],
  display_order: 4
})

create_trait(structure, {
  name: "Stem Thickness",
  description: "Stem/trunk diameter",
  data_type: "select",
  options: %w[thin medium thick],
  applicable_stages: %w[vegetative flowering],
  display_order: 5
})

create_trait(structure, {
  name: "Leaf Type",
  description: "Leaf structure and shape",
  data_type: "select",
  options: ["narrow (sativa)", "broad (indica)", "hybrid"],
  applicable_stages: %w[seedling vegetative],
  display_order: 6
})

# Flowering Category
flowering = TraitCategory.find_or_create_by!(name: "Flowering", organization_id: nil) do |c|
  c.slug = "flowering"
  c.description = "Flower development characteristics"
  c.display_order = 3
  c.icon = "flower"
end

create_trait(flowering, {
  name: "Days to Show Sex",
  description: "Days from flip to visible sex",
  data_type: "numeric",
  unit: "days",
  min_value: 1,
  max_value: 30,
  applicable_stages: %w[pre_flower],
  display_order: 1
})

create_trait(flowering, {
  name: "Stretch Amount",
  description: "Height increase during flower stretch",
  data_type: "select",
  options: ["low (<50%)", "medium (50-100%)", "high (>100%)"],
  applicable_stages: %w[pre_flower flowering],
  display_order: 2
})

create_trait(flowering, {
  name: "Flowering Time",
  description: "Days from flip to harvest ready",
  data_type: "numeric",
  unit: "days",
  min_value: 30,
  max_value: 120,
  applicable_stages: %w[flowering harvest],
  display_order: 3
})

create_trait(flowering, {
  name: "Bud Structure",
  description: "Density and formation of buds",
  data_type: "select",
  options: %w[airy moderate dense rock-hard],
  applicable_stages: %w[flowering],
  display_order: 4
})

create_trait(flowering, {
  name: "Bud Size",
  description: "Size of individual buds/colas",
  data_type: "select",
  options: %w[small medium large chunky],
  applicable_stages: %w[flowering],
  display_order: 5
})

create_trait(flowering, {
  name: "Calyx-to-Leaf Ratio",
  description: "Proportion of calyx to sugar leaf",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Leafy", "5" => "Balanced", "10" => "All Calyx" },
  applicable_stages: %w[flowering],
  display_order: 6
})

# Resin & Trichomes Category
resin = TraitCategory.find_or_create_by!(name: "Resin & Trichomes", organization_id: nil) do |c|
  c.slug = "resin-trichomes"
  c.description = "Trichome production and resin characteristics"
  c.display_order = 4
  c.icon = "sparkles"
end

create_trait(resin, {
  name: "Trichome Coverage",
  description: "Density of trichome coverage (frost level)",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Sparse", "5" => "Average", "10" => "Extremely Frosty" },
  applicable_stages: %w[flowering],
  display_order: 1
})

create_trait(resin, {
  name: "Trichome Head Size",
  description: "Size of trichome heads",
  data_type: "select",
  options: %w[small medium large],
  applicable_stages: %w[flowering],
  display_order: 2
})

create_trait(resin, {
  name: "Trichome Color",
  description: "Color of trichome heads at harvest",
  data_type: "select",
  options: %w[clear cloudy amber mixed],
  applicable_stages: %w[flowering harvest],
  display_order: 3
})

create_trait(resin, {
  name: "Stickiness",
  description: "How sticky/resinous the buds are",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Dry", "5" => "Tacky", "10" => "Extremely Sticky" },
  applicable_stages: %w[flowering harvest],
  display_order: 4
})

# Aroma & Flavor Category
aroma = TraitCategory.find_or_create_by!(name: "Aroma & Flavor", organization_id: nil) do |c|
  c.slug = "aroma-flavor"
  c.description = "Smell and taste characteristics"
  c.display_order = 5
  c.icon = "nose"
end

create_trait(aroma, {
  name: "Aroma Intensity",
  description: "How strong the smell is",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Faint", "5" => "Moderate", "10" => "Extremely Loud" },
  applicable_stages: %w[vegetative flowering curing testing],
  display_order: 1
})

create_trait(aroma, {
  name: "Primary Aroma",
  description: "Dominant smell profile",
  data_type: "select",
  options: %w[earthy citrus sweet diesel floral pine spicy cheese berry tropical skunky chemical fuel],
  applicable_stages: %w[flowering curing testing],
  display_order: 2
})

create_trait(aroma, {
  name: "Secondary Aroma",
  description: "Secondary smell notes",
  data_type: "select",
  options: %w[earthy citrus sweet diesel floral pine spicy cheese berry tropical skunky chemical fuel],
  applicable_stages: %w[flowering curing testing],
  display_order: 3
})

create_trait(aroma, {
  name: "Flavor Match",
  description: "How well the flavor matches the aroma",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "No Match", "5" => "Partial", "10" => "Perfect Match" },
  applicable_stages: %w[testing],
  display_order: 4
})

create_trait(aroma, {
  name: "Smoothness",
  description: "How smooth the smoke/vapor is",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Harsh", "5" => "Average", "10" => "Silky Smooth" },
  applicable_stages: %w[testing],
  display_order: 5
})

# Appearance Category
appearance = TraitCategory.find_or_create_by!(name: "Appearance", organization_id: nil) do |c|
  c.slug = "appearance"
  c.description = "Visual appeal and coloration"
  c.display_order = 6
  c.icon = "eye"
end

create_trait(appearance, {
  name: "Bag Appeal",
  description: "Overall visual attractiveness",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Poor", "5" => "Average", "10" => "Stunning" },
  applicable_stages: %w[harvest curing],
  display_order: 1
})

create_trait(appearance, {
  name: "Color",
  description: "Dominant color of buds",
  data_type: "select",
  options: %w[green purple pink orange red multicolor],
  applicable_stages: %w[flowering harvest],
  display_order: 2
})

create_trait(appearance, {
  name: "Trim Ease",
  description: "How easy the plant is to trim",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Difficult", "5" => "Average", "10" => "Very Easy" },
  applicable_stages: %w[harvest],
  display_order: 3
})

# Yield Category
yield_cat = TraitCategory.find_or_create_by!(name: "Harvest & Yield", organization_id: nil) do |c|
  c.slug = "harvest-yield"
  c.description = "Harvest metrics and yield data"
  c.display_order = 7
  c.icon = "scale"
end

create_trait(yield_cat, {
  name: "Wet Weight",
  description: "Weight immediately after harvest",
  data_type: "numeric",
  unit: "g",
  min_value: 0,
  max_value: 10000,
  applicable_stages: %w[harvest],
  display_order: 1
})

create_trait(yield_cat, {
  name: "Dry Weight",
  description: "Weight after drying",
  data_type: "numeric",
  unit: "g",
  min_value: 0,
  max_value: 5000,
  applicable_stages: %w[drying curing],
  display_order: 2
})

create_trait(yield_cat, {
  name: "Yield Rating",
  description: "Subjective yield assessment",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Low", "5" => "Average", "10" => "Exceptional" },
  applicable_stages: %w[harvest],
  display_order: 3
})

# Effects Category
effects = TraitCategory.find_or_create_by!(name: "Effects", organization_id: nil) do |c|
  c.slug = "effects"
  c.description = "Subjective effects evaluation"
  c.display_order = 8
  c.icon = "brain"
end

create_trait(effects, {
  name: "Potency",
  description: "Overall strength of effects",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "Very Mild", "5" => "Moderate", "10" => "Extremely Potent" },
  applicable_stages: %w[testing],
  display_order: 1
})

create_trait(effects, {
  name: "Onset Speed",
  description: "How quickly effects are felt",
  data_type: "select",
  options: %w[instant gradual slow],
  applicable_stages: %w[testing],
  display_order: 2
})

create_trait(effects, {
  name: "Duration",
  description: "How long effects last",
  data_type: "select",
  options: ["short (<1hr)", "medium (1-2hr)", "long (2-4hr)", "very long (>4hr)"],
  applicable_stages: %w[testing],
  display_order: 3
})

create_trait(effects, {
  name: "Primary Effect",
  description: "Dominant effect type",
  data_type: "select",
  options: %w[relaxing uplifting euphoric creative focused sedating energizing],
  applicable_stages: %w[testing],
  display_order: 4
})

create_trait(effects, {
  name: "Body Effect",
  description: "Intensity of body effects",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "None", "5" => "Moderate", "10" => "Heavy Body High" },
  applicable_stages: %w[testing],
  display_order: 5
})

create_trait(effects, {
  name: "Head Effect",
  description: "Intensity of cerebral effects",
  data_type: "scale",
  min_value: 1,
  max_value: 10,
  scale_labels: { "1" => "None", "5" => "Moderate", "10" => "Intense Head High" },
  applicable_stages: %w[testing],
  display_order: 6
})

puts "Created #{TraitCategory.count} trait categories with #{TraitDefinition.count} trait definitions."
puts "Done!"
