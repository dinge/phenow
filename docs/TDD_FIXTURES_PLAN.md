# TDD with Minitest & Fixtures Plan

> Comprehensive plan for strict TDD testing with Minitest and realistic fixtures

## Philosophy

**Why Minitest + Fixtures over RSpec + FactoryBot?**

| Aspect | Minitest + Fixtures | RSpec + FactoryBot |
|--------|--------------------|--------------------|
| Speed | Faster (fixtures loaded once) | Slower (objects built per test) |
| Rails Integration | Native, no extra gems | Requires additional gems |
| Data Consistency | Same data in every test | Different data each run |
| Learning Curve | Simple Ruby assertions | DSL to learn |
| Debugging | Predictable state | Dynamic state |
| Reusability | Fixtures = seeds = dev data | Factories are test-only |

**For Phenow, fixtures are ideal because:**
1. Rich domain model with deep relationships
2. We want to test realistic phenohunting scenarios
3. Fixtures double as development seed data
4. Consistent test data improves debugging
5. Rails 8 convention over configuration

---

## Data Sources for Realistic Fixtures

### Primary Sources

| Source | Data | URL |
|--------|------|-----|
| **Kushy Dataset** | 2000+ strains, effects, flavors | [github.com/kushyapp/cannabis-dataset](https://github.com/kushyapp/cannabis-dataset) |
| **Leafly** | Strain profiles, THC/CBD, lineage | [leafly.com/strains](https://www.leafly.com/strains) |
| **SeedFinder** | Genetic lineage trees, breeder info | [seedfinder.eu](https://seedfinder.eu/en) |
| **The Cannabis API** | Strain details, effects, flavors | [the-cannabis-api.vercel.app](https://the-cannabis-api.vercel.app/) |

### Verified Strain Data (for fixtures)

#### GMO (Garlic Cookies)
- **Breeder**: Mamiko Seeds (Spain)
- **Lineage**: Chemdawg x Girl Scout Cookies
- **Type**: Indica-dominant (90/10)
- **THC**: 25-30%
- **CBD**: <1%
- **Flowering**: 70+ days
- **Terpenes**: Caryophyllene (dominant), Myrcene, Limonene
- **Aromas**: Garlic, mushroom, onion, diesel, earth
- **Effects**: Heavy relaxation, euphoria, sedation
- **Source**: [Leafly GMO Cookies](https://www.leafly.com/strains/gmo-cookies)

#### Zkittlez (The Original Z)
- **Breeder**: 3rd Gen Family / Terp Hogz
- **Lineage**: Grape Ape x Grapefruit x Unknown
- **Type**: Indica-dominant (60/40)
- **THC**: 15-23%
- **CBD**: <1%
- **Flowering**: 55-60 days
- **Terpenes**: Humulene, Limonene, Pinene, Myrcene
- **Aromas**: Sweet berries, tropical fruit, grape, candy
- **Effects**: Calming, focused, happy, creative
- **Awards**: 2016 Emerald Cup 1st Place
- **Source**: [Leafly Zkittlez](https://www.leafly.com/strains/zkittlez)

#### Wedding Cake
- **Breeder**: Seed Junky Genetics
- **Lineage**: Triangle Kush x Animal Mints
- **Type**: Indica-dominant (60/40)
- **THC**: 22-27%
- **CBD**: <1%
- **Flowering**: 55-60 days
- **Terpenes**: Limonene, Caryophyllene, Myrcene
- **Aromas**: Vanilla, sweet, tangy, earthy
- **Effects**: Relaxing, euphoric, uplifting

#### Gelato #41
- **Breeder**: Cookie Fam / Sherbinskis
- **Lineage**: Sunset Sherbet x Thin Mint GSC
- **Type**: Hybrid (55/45 indica)
- **THC**: 20-25%
- **CBD**: <1%
- **Flowering**: 56-63 days
- **Terpenes**: Limonene, Caryophyllene, Humulene
- **Aromas**: Sweet, citrus, berry, lavender
- **Effects**: Euphoric, relaxed, creative

#### Purple Punch
- **Breeder**: Supernova Gardens
- **Lineage**: Larry OG x Granddaddy Purple
- **Type**: Indica-dominant (80/20)
- **THC**: 18-24%
- **CBD**: <1%
- **Flowering**: 50-60 days
- **Terpenes**: Limonene, Caryophyllene, Pinene
- **Aromas**: Grape, blueberry, vanilla, sweet
- **Effects**: Sedating, relaxing, sleepy

#### Runtz
- **Breeder**: Cookies / Runtz Crew
- **Lineage**: Zkittlez x Gelato
- **Type**: Hybrid (50/50)
- **THC**: 19-29%
- **CBD**: <1%
- **Flowering**: 55-65 days
- **Terpenes**: Caryophyllene, Limonene, Linalool
- **Aromas**: Sweet candy, tropical fruit, creamy
- **Effects**: Euphoric, uplifting, relaxing

---

## The Fixture Domain World

### Scenario: "Exotic Genetics Collective - GMO x Zkittlez F1 Phenohunt"

A realistic phenohunting scenario that exercises all models and relationships.

```
Organization: Exotic Genetics Collective
├── Teams
│   ├── Breeding Team (main phenohunting)
│   └── Testing Team (smoke tests, lab coordination)
│
├── Users
│   ├── Marcus (Head Breeder) - owner of Breeding Team
│   ├── Sarah (Assistant Breeder) - admin
│   ├── Jake (Tester) - member of Testing Team
│   └── Emily (Viewer) - viewer, documentation
│
├── Strains (6 real strains + 2 crosses)
│   ├── GMO (parent)
│   ├── Zkittlez (parent)
│   ├── Wedding Cake
│   ├── Gelato #41
│   ├── Purple Punch
│   ├── Runtz
│   ├── GMO x Zkittlez (F1 cross - project strain)
│   └── Runtz x Wedding Cake (another cross)
│
├── Projects
│   ├── "GMO x Zkittlez F1 Hunt" (active, main project)
│   │   ├── Goals: High THC, Zkittlez terps, GMO structure
│   │   └── Plants: #1-#10 (various stages/statuses)
│   │
│   └── "Purple Punch Preservation" (completed, reference)
│       └── Plants: PP-1 to PP-5 (all archived)
│
└── Complete Data Chain
    ├── Plants with stage transitions
    ├── Weekly observations with trait scores
    ├── Photos at each stage
    ├── Lab tests for harvested plants
    ├── Selections with reasoning
    ├── Comments and discussions
    └── Tags for organization
```

### Plant Distribution (GMO x Zkittlez Hunt)

| Plant | Status | Stage | Sex | Notable |
|-------|--------|-------|-----|---------|
| #1 | keeper | testing | female | Best terps, keeper mother |
| #2 | culled | flowering | male | Early male, culled |
| #3 | active | flowering | female | Week 6, promising |
| #4 | keeper | curing | female | High yield, breeding father candidate |
| #5 | culled | vegetative | female | Weak vigor, culled early |
| #6 | active | flowering | female | Week 4, heavy GMO leaner |
| #7 | harvested | drying | female | Just harvested |
| #8 | active | vegetative | unknown | Still in veg |
| #9 | culled | seedling | unknown | Failed to thrive |
| #10 | active | pre_flower | female | Just flipped |

---

## Fixture File Structure

```
test/
├── fixtures/
│   ├── users.yml                    # 4 users
│   ├── organizations.yml            # 1 organization
│   ├── teams.yml                    # 2 teams
│   ├── memberships.yml              # 5 memberships
│   ├── strains.yml                  # 8 strains (6 real + 2 crosses)
│   ├── strain_lineages.yml          # Parent relationships
│   ├── projects.yml                 # 2 projects
│   ├── project_goals.yml            # 4 goals
│   ├── plants.yml                   # 15 plants (10 + 5)
│   ├── plant_stage_transitions.yml  # ~50 transitions
│   ├── trait_categories.yml         # 8 categories (from seeds)
│   ├── trait_definitions.yml        # 30+ definitions (from seeds)
│   ├── observations.yml             # ~30 observations
│   ├── trait_values.yml             # ~150 trait values
│   ├── photos.yml                   # ~20 photos
│   ├── lab_tests.yml                # 3 lab tests
│   ├── selections.yml               # 6 selections
│   ├── comments.yml                 # 10 comments
│   ├── tags.yml                     # 5 tags
│   └── taggings.yml                 # 15 taggings
│
├── models/
│   ├── user_test.rb
│   ├── organization_test.rb
│   ├── team_test.rb
│   ├── membership_test.rb
│   ├── strain_test.rb
│   ├── strain_lineage_test.rb
│   ├── project_test.rb
│   ├── project_goal_test.rb
│   ├── plant_test.rb
│   ├── plant_stage_transition_test.rb
│   ├── trait_category_test.rb
│   ├── trait_definition_test.rb
│   ├── observation_test.rb
│   ├── trait_value_test.rb
│   ├── photo_test.rb
│   ├── lab_test_test.rb
│   ├── selection_test.rb
│   ├── comment_test.rb
│   ├── tag_test.rb
│   └── tagging_test.rb
│
├── controllers/
│   └── (integration tests when controllers exist)
│
└── system/
    └── (system tests when UI exists)
```

---

## Sample Fixture Files

### users.yml
```yaml
marcus:
  email: marcus@exoticgenetics.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
  name: Marcus Johnson
  timezone: America/Los_Angeles
  preferences: {}

sarah:
  email: sarah@exoticgenetics.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
  name: Sarah Chen
  timezone: America/Los_Angeles
  preferences: {}

jake:
  email: jake@exoticgenetics.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
  name: Jake Williams
  timezone: America/Denver
  preferences: {}

emily:
  email: emily@exoticgenetics.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
  name: Emily Rodriguez
  timezone: America/New_York
  preferences: {}
```

### strains.yml
```yaml
gmo:
  organization: exotic_genetics
  name: GMO
  slug: gmo
  breeder: Mamiko Seeds
  strain_type: indica
  description: >
    Also known as Garlic Cookies. A potent indica-dominant hybrid
    with pungent garlic, mushroom, and onion aromas. Known for
    heavy relaxation and high THC content.
  lineage_text: Chemdawg x Girl Scout Cookies
  genetics_type: regular
  flowering_time_min: 70
  flowering_time_max: 77
  thc_min: 25.0
  thc_max: 30.0
  cbd_min: 0.0
  cbd_max: 1.0
  dominant_terpenes:
    - caryophyllene
    - myrcene
    - limonene
  effects:
    - relaxing
    - euphoric
    - sedating
  aromas:
    - garlic
    - mushroom
    - onion
    - diesel
    - earth
  public: true
  verified: true
  metadata: {}

zkittlez:
  organization: exotic_genetics
  name: Zkittlez
  slug: zkittlez
  breeder: 3rd Gen Family / Terp Hogz
  strain_type: indica
  description: >
    Award-winning indica-dominant hybrid known for its candy-like
    grape and tropical fruit flavors. 2016 Emerald Cup winner.
  lineage_text: Grape Ape x Grapefruit x Unknown
  genetics_type: feminized
  flowering_time_min: 55
  flowering_time_max: 60
  thc_min: 15.0
  thc_max: 23.0
  cbd_min: 0.0
  cbd_max: 1.0
  dominant_terpenes:
    - humulene
    - limonene
    - pinene
    - myrcene
  effects:
    - calming
    - focused
    - happy
    - creative
  aromas:
    - berry
    - grape
    - tropical
    - candy
    - sweet
  public: true
  verified: true
  metadata: {}

gmo_x_zkittlez:
  organization: exotic_genetics
  name: GMO x Zkittlez
  slug: gmo-x-zkittlez
  breeder: Exotic Genetics Collective
  strain_type: hybrid
  description: >
    F1 cross combining GMO's potency and structure with Zkittlez's
    legendary terpene profile. Goal: high THC with fruity/gassy nose.
  lineage_text: GMO x Zkittlez
  genetics_type: regular
  flowering_time_min: 60
  flowering_time_max: 70
  thc_min: 20.0
  thc_max: 28.0
  cbd_min: 0.0
  cbd_max: 1.0
  dominant_terpenes:
    - caryophyllene
    - limonene
    - myrcene
  effects:
    - relaxing
    - euphoric
    - creative
  aromas:
    - garlic
    - fruit
    - gas
  public: false
  verified: false
  metadata: {}
```

### plants.yml
```yaml
plant_1:
  project: gmo_zkittlez_hunt
  strain: gmo_x_zkittlez
  identifier: "#1"
  name: "Gassy Grape"
  source_type: seed
  sex: female
  current_stage: testing
  status: keeper
  germination_date: <%= 90.days.ago.to_date %>
  flip_date: <%= 60.days.ago.to_date %>
  harvest_date: <%= 14.days.ago.to_date %>
  notes: >
    Outstanding terpene expression - perfect balance of GMO gas
    and Zkittlez fruit. Dense structure, heavy trichome coverage.
    Selected as keeper mother.
  metadata:
    pheno_expression: zkittlez_leaning
    trichome_density: very_high

plant_2:
  project: gmo_zkittlez_hunt
  strain: gmo_x_zkittlez
  identifier: "#2"
  name: ~
  source_type: seed
  sex: male
  current_stage: flowering
  status: culled
  germination_date: <%= 90.days.ago.to_date %>
  flip_date: <%= 60.days.ago.to_date %>
  harvest_date: ~
  notes: Male identified at day 10 of flower. Culled to protect females.
  metadata: {}

plant_3:
  project: gmo_zkittlez_hunt
  strain: gmo_x_zkittlez
  identifier: "#3"
  name: ~
  source_type: seed
  sex: female
  current_stage: flowering
  status: active
  germination_date: <%= 90.days.ago.to_date %>
  flip_date: <%= 42.days.ago.to_date %>
  harvest_date: ~
  notes: Week 6 of flower. Heavy frost, leaning GMO on structure.
  metadata:
    week_of_flower: 6
```

### observations.yml
```yaml
plant_1_veg_week_2:
  plant: plant_1
  observed_by: marcus
  observed_at: <%= 76.days.ago %>
  stage: vegetative
  week_number: 2
  overall_score: 8.5
  notes: >
    Strong vigor, healthy green color. Broad leaves suggesting
    Zkittlez influence. No deficiencies observed.

plant_1_flower_week_4:
  plant: plant_1
  observed_by: marcus
  observed_at: <%= 32.days.ago %>
  stage: flowering
  week_number: 4
  overall_score: 9.0
  notes: >
    Exceptional frost development. Nose is coming through strong -
    gassy grape with garlic undertones. Dense bud structure.
    Definitely a keeper candidate.

plant_1_harvest:
  plant: plant_1
  observed_by: sarah
  observed_at: <%= 14.days.ago %>
  stage: harvest
  week_number: ~
  overall_score: 9.5
  notes: >
    Harvested at day 63 of flower. Trichomes 80% cloudy, 20% amber.
    Incredible nose - the whole room smells like grape candy and
    garlic bread. Easy trim, excellent calyx-to-leaf ratio.
```

### selections.yml
```yaml
plant_1_selection:
  plant: plant_1
  selected_by: marcus
  decision: keep
  selected_at: <%= 10.days.ago %>
  reasoning: >
    Best phenotype expression of the entire hunt. Perfect balance of
    both parents - GMO's structure and potency with Zkittlez's
    terpene profile. Dense, frosty buds with excellent bag appeal.
    Lab results pending but smoke test showed high potency with
    clean, smooth flavor. This is our keeper mother.
  score: 9.5
  standout_traits:
    - terpene_profile
    - trichome_coverage
    - bud_structure
    - bag_appeal
  concerns:
    - slightly_longer_flowering_time

plant_2_selection:
  plant: plant_2
  selected_by: marcus
  decision: cull
  selected_at: <%= 50.days.ago %>
  reasoning: >
    Male identified at day 10 of flower. Had to cull to protect
    the female plants from pollination. No pollen was released.
  score: ~
  standout_traits: []
  concerns:
    - male
```

---

## Test Coverage Plan

### Model Tests

Each model test file should cover:

1. **Validations** - presence, format, uniqueness, inclusion
2. **Associations** - belongs_to, has_many, through
3. **Scopes** - custom query scopes
4. **Callbacks** - before/after hooks
5. **Instance methods** - business logic
6. **Class methods** - finders, builders

### Example: plant_test.rb
```ruby
# test/models/plant_test.rb
require "test_helper"

class PlantTest < ActiveSupport::TestCase
  # Fixtures
  # Uses: plants(:plant_1), plants(:plant_3), projects(:gmo_zkittlez_hunt)

  # === Validations ===

  test "valid plant" do
    plant = plants(:plant_1)
    assert plant.valid?
  end

  test "requires project" do
    plant = Plant.new(identifier: "#99")
    assert_not plant.valid?
    assert_includes plant.errors[:project], "must exist"
  end

  test "requires identifier" do
    plant = plants(:plant_1)
    plant.identifier = nil
    assert_not plant.valid?
    assert_includes plant.errors[:identifier], "can't be blank"
  end

  test "identifier unique within project" do
    duplicate = Plant.new(
      project: projects(:gmo_zkittlez_hunt),
      identifier: "#1",  # Already exists
      source_type: "seed"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:identifier], "has already been taken"
  end

  test "status must be valid" do
    plant = plants(:plant_1)
    plant.status = "invalid_status"
    assert_not plant.valid?
    assert_includes plant.errors[:status], "is not included in the list"
  end

  # === Associations ===

  test "belongs to project" do
    plant = plants(:plant_1)
    assert_equal projects(:gmo_zkittlez_hunt), plant.project
  end

  test "has many observations" do
    plant = plants(:plant_1)
    assert plant.observations.count >= 3
  end

  test "has many selections" do
    plant = plants(:plant_1)
    assert plant.selections.any?
  end

  # === Scopes ===

  test "scope active returns active plants" do
    active = Plant.active
    assert active.all? { |p| p.status == "active" }
  end

  test "scope keepers returns keeper plants" do
    keepers = Plant.keepers
    assert keepers.all? { |p| p.status == "keeper" }
    assert_includes keepers, plants(:plant_1)
  end

  test "scope in_stage filters by stage" do
    flowering = Plant.in_stage("flowering")
    assert flowering.all? { |p| p.current_stage == "flowering" }
  end

  # === Instance Methods ===

  test "keeper? returns true for keeper status" do
    assert plants(:plant_1).keeper?
    assert_not plants(:plant_3).keeper?
  end

  test "days_in_flower calculates correctly" do
    plant = plants(:plant_3)
    expected = (Date.current - plant.flip_date).to_i
    assert_equal expected, plant.days_in_flower
  end

  test "transition_to updates stage and creates transition" do
    plant = plants(:plant_8)  # In vegetative
    assert_equal "vegetative", plant.current_stage

    plant.transition_to("pre_flower", users(:marcus))

    assert_equal "pre_flower", plant.current_stage
    assert plant.stage_transitions.exists?(to_stage: "pre_flower")
  end

  # === Callbacks ===

  test "sets default status on create" do
    plant = Plant.create!(
      project: projects(:gmo_zkittlez_hunt),
      identifier: "#99",
      source_type: "seed"
    )
    assert_equal "active", plant.status
  end

  test "sets default stage on create" do
    plant = Plant.create!(
      project: projects(:gmo_zkittlez_hunt),
      identifier: "#99",
      source_type: "seed"
    )
    assert_equal "germination", plant.current_stage
  end
end
```

---

## Integration with Seeds

The fixtures can be loaded as seed data for development:

### db/seeds.rb (updated approach)
```ruby
# frozen_string_literal: true

# Load fixtures as seed data for development
if Rails.env.development? || Rails.env.staging?
  require 'active_record/fixtures'

  puts "Loading fixture data for development..."

  # Load in dependency order
  fixture_files = %w[
    users
    organizations
    teams
    memberships
    trait_categories
    trait_definitions
    strains
    strain_lineages
    projects
    project_goals
    plants
    plant_stage_transitions
    observations
    trait_values
    photos
    lab_tests
    selections
    comments
    tags
    taggings
  ]

  ActiveRecord::FixtureSet.create_fixtures(
    Rails.root.join('test/fixtures'),
    fixture_files
  )

  puts "Loaded #{User.count} users"
  puts "Loaded #{Strain.count} strains"
  puts "Loaded #{Project.count} projects"
  puts "Loaded #{Plant.count} plants"
  puts "Loaded #{Observation.count} observations"
  puts "Done!"
end
```

---

## Implementation Steps

### Phase 1: Setup (Sonnet)
1. Remove RSpec and FactoryBot from Gemfile
2. Remove spec/ directory
3. Configure Minitest in test_helper.rb
4. Create test directory structure

### Phase 2: Fixtures (Sonnet, guided by Opus)
1. Create all 20 fixture files with realistic data
2. Ensure referential integrity
3. Use ERB for dynamic dates and computed values

### Phase 3: Model Tests (Sonnet)
1. Generate test files for all 18 models
2. Test validations, associations, scopes
3. Test business logic methods
4. Aim for 100% model coverage

### Phase 4: Integration (Sonnet)
1. Update seeds.rb to load fixtures
2. Verify `rails db:seed` works
3. Manual testing with fixture data

### Phase 5: CI Setup (Sonnet)
1. Configure GitHub Actions for Minitest
2. Add test coverage reporting
3. Ensure all tests pass

---

## Success Criteria

- [ ] All RSpec/FactoryBot references removed
- [ ] 20 fixture files with realistic data
- [ ] 18 model test files with comprehensive coverage
- [ ] All tests green (`rails test`)
- [ ] `rails db:seed` loads fixture data
- [ ] Development environment has realistic data to work with
- [ ] CI pipeline runs tests successfully

---

## Resources

- [Kushy Cannabis Dataset](https://github.com/kushyapp/cannabis-dataset)
- [Leafly Strain Database](https://www.leafly.com/strains)
- [SeedFinder Strain Database](https://seedfinder.eu/en)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
