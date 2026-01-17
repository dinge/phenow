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

## Data Sources - Comprehensive Analysis

### Tier 1: Bulk Import Sources (Production Data)

| Source | Strains | Breeders | License | Format | Status |
|--------|---------|----------|---------|--------|--------|
| **[Kushy Dataset](https://github.com/kushyapp/cannabis-dataset)** | 2,000+ | 500+ | MIT | CSV/SQL | **Active - Primary** |
| **[SeedRadar](https://seedradar.net/)** | 11,883 | 1,783 | CC BY-NC-SA 4.0 | API | **Active - SeedFinder Archive** |
| **[Mendeley Research](https://data.mendeley.com/datasets/6zwcgrttkp/1)** | 800+ | - | CC BY 4.0 | CSV | **Active - Research Quality** |
| **[Kaggle Leafly](https://www.kaggle.com/datasets/kingburrito666/cannabis-strains)** | 2,000+ | - | Various | CSV/JSON | **Active** |
| **[The Cannabis API](https://the-cannabis-api.vercel.app/)** | 2,000+ | - | Free | REST | **Active** |

### Tier 2: Historical/Archive Sources

| Source | Data | Status | Notes |
|--------|------|--------|-------|
| **SeedFinder.eu** | 38,000+ strains, 2,000+ breeders, lineage trees | **API Shutdown July 2024** | Best lineage data ever compiled |
| **[SeedRadar Archive Project](https://seedradar.net/)** | Preserving SeedFinder via Archive.org | **In Progress** | Mining Wayback Machine snapshots |
| **[Wayback Machine](https://web.archive.org/)** | Historical SeedFinder pages | **Available** | Use waybackpack tool to extract |

### Kushy Dataset - Primary Import Source

**34 Columns Available:**
```
id, status, sort, name, slug, image, description, type, crosses, breeder,
effects, ailment, flavor, location, terpenes, thc, thca, thcv, cbd, cbda,
cbdv, cbn, cbg, cbgm, cbgv, cbc, cbcv, cbv, cbe, cbt, cbl
```

**Sample Records:**
| Name | Type | Breeder | Effects | Ailments |
|------|------|---------|---------|----------|
| Acapulco Gold | Sativa | - | Happy, Euphoric, Uplifted | Depression, Stress, Pain |
| Afghan Kush | Hybrid | White Label Co. | - | - |
| Afghani | Indica | - | Relaxed, Sleepy, Euphoric | Stress, Insomnia, Pain |
| GSC (Girl Scout Cookies) | Hybrid | Cookie Fam | Euphoric, Happy, Relaxed | Stress, Depression, Pain |

### SeedRadar - SeedFinder Archive (Secondary Import)

**Preservation Effort:**
- Mining Archive.org for pre-July 2024 SeedFinder data
- Rebuilding relational database with genetic lineages
- Planning torrent distribution for community backup
- CC BY-NC-SA 4.0 license

**Current Database:**
- 11,883 cannabis varieties
- 11,542 strains from 1,783 breeders
- 384 clone-only strains
- Genetic lineage tracking

### Wayback Machine Strategy for SeedFinder Data

```bash
# Install waybackpack
pip install waybackpack

# Download SeedFinder strain pages (pre-API shutdown)
waybackpack seedfinder.eu/en/database/strains \
  --from-date 2023 \
  --to-date 202406 \
  --output-dir ./seedfinder_archive

# Download breeder pages
waybackpack seedfinder.eu/en/database/breeder \
  --from-date 2023 \
  --to-date 202406 \
  --output-dir ./seedfinder_breeders
```

---

## Two-Tier Fixture Strategy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TIER 1: PRODUCTION DATA                              │
│                    (Bulk Import → Go-Live Ready)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  db/data/                                                                    │
│  ├── kushy_strains.csv        # 2,000+ strains from Kushy                   │
│  ├── seedradar_strains.csv    # 11,000+ strains from SeedRadar              │
│  ├── breeders.csv             # Extracted/merged breeder data               │
│  └── terpenes.yml             # Standardized terpene definitions            │
│                                                                              │
│  Imported via: rake import:strains import:breeders                          │
│  Result: Production-ready strain library for go-live                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TIER 2: SCENARIO DATA                                │
│                    (Hand-Crafted Test Fixtures)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  test/fixtures/                                                              │
│  ├── organizations.yml        # "Exotic Genetics Collective"                │
│  ├── users.yml                # 4 users with different roles                │
│  ├── teams.yml                # Breeding Team, Testing Team                 │
│  ├── projects.yml             # Active phenohunt + completed project        │
│  ├── plants.yml               # 15 plants across all stages/statuses        │
│  ├── observations.yml         # Weekly observation history                  │
│  ├── selections.yml           # Keep/cull decisions with reasoning          │
│  └── ...                      # Full workflow coverage                      │
│                                                                              │
│  Purpose: Test all business logic, workflows, edge cases                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### What Gets Imported vs. Hand-Crafted

| Data Type | Source | Method | Count | Purpose |
|-----------|--------|--------|-------|---------|
| **Strains** | Kushy + SeedRadar | Bulk import | 2,000-10,000 | Production strain library |
| **Breeders** | Extract from imports | Bulk import | 500-1,500 | Searchable breeder database |
| **Terpenes** | Static YAML | Manual | 17 | Standardized list |
| **Effects** | Kushy + normalize | Import | 25 | Dropdown options |
| **Aromas/Flavors** | Kushy + normalize | Import | 40 | Dropdown options |
| **Organizations** | Fixtures | Hand-craft | 1-2 | Test multi-tenancy |
| **Users** | Fixtures | Hand-craft | 4-6 | Test roles/permissions |
| **Teams** | Fixtures | Hand-craft | 2-3 | Test team features |
| **Projects** | Fixtures | Hand-craft | 2-3 | Test workflows |
| **Plants** | Fixtures | Hand-craft | 15-20 | Test all stages/statuses |
| **Observations** | Fixtures | Hand-craft | 50+ | Test trait recording |
| **Selections** | Fixtures | Hand-craft | 10+ | Test decisions |

---

## Verified Strain Data (Hand-Crafted Fixtures)

### GMO (Garlic Cookies)
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

### Zkittlez (The Original Z)
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

### Wedding Cake
- **Breeder**: Seed Junky Genetics
- **Lineage**: Triangle Kush x Animal Mints
- **Type**: Indica-dominant (60/40)
- **THC**: 22-27%
- **Flowering**: 55-60 days
- **Terpenes**: Limonene, Caryophyllene, Myrcene
- **Aromas**: Vanilla, sweet, tangy, earthy

### Gelato #41
- **Breeder**: Cookie Fam / Sherbinskis
- **Lineage**: Sunset Sherbet x Thin Mint GSC
- **Type**: Hybrid (55/45 indica)
- **THC**: 20-25%
- **Flowering**: 56-63 days
- **Terpenes**: Limonene, Caryophyllene, Humulene

### Purple Punch
- **Breeder**: Supernova Gardens
- **Lineage**: Larry OG x Granddaddy Purple
- **Type**: Indica-dominant (80/20)
- **THC**: 18-24%
- **Flowering**: 50-60 days

### Runtz
- **Breeder**: Cookies / Runtz Crew
- **Lineage**: Zkittlez x Gelato
- **Type**: Hybrid (50/50)
- **THC**: 19-29%
- **Flowering**: 55-65 days

---

## Standardized Reference Data

### Terpene Definitions (db/data/terpenes.yml)

```yaml
primary_terpenes:
  - name: myrcene
    aroma: earthy, musky, herbal, clove
    effects: sedating, relaxing, pain relief
    found_in: mangoes, hops, lemongrass

  - name: limonene
    aroma: citrus, lemon, orange
    effects: mood elevation, stress relief, energizing
    found_in: citrus peels, juniper

  - name: caryophyllene
    aroma: spicy, peppery, woody
    effects: anti-inflammatory, pain relief
    found_in: black pepper, cloves, cinnamon
    note: binds to CB2 receptors

  - name: pinene
    aroma: pine, earthy, fresh
    effects: alertness, memory retention, anti-inflammatory
    found_in: pine needles, rosemary, basil

  - name: linalool
    aroma: floral, lavender, sweet
    effects: calming, anti-anxiety, sedating
    found_in: lavender, coriander

  - name: humulene
    aroma: hoppy, earthy, woody
    effects: appetite suppressant, anti-inflammatory
    found_in: hops, sage, ginseng

  - name: terpinolene
    aroma: piney, floral, herbal, citrus
    effects: uplifting, creative
    found_in: nutmeg, cumin, apples

secondary_terpenes:
  - ocimene
  - bisabolol
  - valencene
  - geraniol
  - camphene
  - borneol
  - sabinene
  - phytol
  - eucalyptol
  - nerolidol
```

### Effect Categories (Standardized)

```yaml
effects:
  positive:
    - relaxed
    - happy
    - euphoric
    - uplifted
    - creative
    - focused
    - energetic
    - talkative
    - giggly
    - hungry
    - sleepy
    - tingly
    - aroused

  medical:
    - stress
    - anxiety
    - depression
    - pain
    - insomnia
    - inflammation
    - nausea
    - appetite_loss
    - muscle_spasms
    - headaches

  negative:
    - dry_mouth
    - dry_eyes
    - paranoid
    - dizzy
    - anxious
    - headache
```

### Aroma/Flavor Categories (Standardized)

```yaml
aromas:
  earthy: [earthy, woody, herbal, mossy, soil]
  citrus: [lemon, orange, lime, grapefruit, citrus]
  sweet: [sweet, candy, sugary, honey, vanilla]
  fruity: [berry, grape, tropical, apple, mango]
  floral: [floral, lavender, rose, jasmine]
  spicy: [spicy, pepper, cinnamon, clove]
  diesel: [diesel, fuel, chemical, gas]
  skunky: [skunk, pungent, dank]
  pine: [pine, forest, cedar, minty]
  cheese: [cheese, dairy, funky]
  nutty: [nutty, almond, coffee]
```

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
├── Strains (references imported strains + custom crosses)
│   ├── GMO (parent) - from import
│   ├── Zkittlez (parent) - from import
│   ├── Wedding Cake - from import
│   ├── Gelato #41 - from import
│   ├── Purple Punch - from import
│   ├── Runtz - from import
│   ├── GMO x Zkittlez (F1 cross - project strain) - fixture
│   └── Runtz x Wedding Cake (another cross) - fixture
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

## Import Pipeline

### Directory Structure

```
db/
├── data/
│   ├── kushy_strains.csv           # Downloaded from GitHub
│   ├── seedradar_strains.csv       # Exported from SeedRadar (if API available)
│   ├── breeders.csv                # Consolidated breeder list
│   ├── terpenes.yml                # Standardized terpene definitions
│   ├── effects.yml                 # Standardized effect list
│   └── aromas.yml                  # Standardized aroma list
├── migrate/
└── seeds.rb
```

### Import Rake Tasks

```ruby
# lib/tasks/import.rake

namespace :import do
  desc "Import strains from Kushy CSV"
  task strains: :environment do
    require 'csv'

    file = Rails.root.join('db/data/kushy_strains.csv')
    imported = 0
    skipped = 0

    CSV.foreach(file, headers: true) do |row|
      strain = Strain.find_or_initialize_by(
        slug: row['slug'].presence || row['name'].to_s.parameterize,
        organization: Organization.default
      )

      if strain.new_record?
        strain.assign_attributes(
          name: row['name'],
          breeder: row['breeder'].presence,
          strain_type: map_strain_type(row['type']),
          description: row['description'],
          lineage_text: row['crosses'],
          thc_min: parse_cannabinoid(row['thc'])&.first,
          thc_max: parse_cannabinoid(row['thc'])&.last,
          cbd_min: parse_cannabinoid(row['cbd'])&.first,
          cbd_max: parse_cannabinoid(row['cbd'])&.last,
          dominant_terpenes: parse_array(row['terpenes']),
          effects: parse_array(row['effects']),
          aromas: parse_array(row['flavor']),
          public: true,
          verified: false
        )

        if strain.save
          imported += 1
        else
          puts "Error importing #{row['name']}: #{strain.errors.full_messages.join(', ')}"
          skipped += 1
        end
      else
        skipped += 1
      end
    end

    puts "Imported: #{imported}, Skipped: #{skipped}"
    puts "Total strains: #{Strain.count}"
  end

  desc "Import breeders from CSV"
  task breeders: :environment do
    # Extract unique breeders from strains and create breeder records
    # (if we add a Breeder model later)
    breeders = Strain.where.not(breeder: [nil, '']).pluck(:breeder).uniq
    puts "Found #{breeders.count} unique breeders"
  end

  desc "Import all data"
  task all: [:strains, :breeders] do
    puts "Import complete!"
  end

  private

  def map_strain_type(type)
    case type&.downcase
    when 'sativa' then 'sativa'
    when 'indica' then 'indica'
    when 'hybrid' then 'hybrid'
    else 'hybrid'
    end
  end

  def parse_cannabinoid(value)
    return nil if value.blank?
    # Handle formats like "25%", "20-25%", "25"
    numbers = value.to_s.scan(/[\d.]+/).map(&:to_f)
    return nil if numbers.empty?
    numbers.length == 1 ? [numbers.first, numbers.first] : [numbers.min, numbers.max]
  end

  def parse_array(value)
    return [] if value.blank?
    value.to_s.split(',').map(&:strip).map(&:downcase).reject(&:blank?)
  end
end
```

### SeedRadar Data Export Script

```ruby
# lib/tasks/seedradar.rake

namespace :seedradar do
  desc "Fetch strains from SeedRadar API (if available)"
  task fetch: :environment do
    require 'net/http'
    require 'json'

    # Note: SeedRadar API documentation not public
    # This is a placeholder for when API becomes available

    puts "SeedRadar API integration pending..."
    puts "Current workaround: Export data manually from seedradar.net"
    puts "Or use Wayback Machine to extract historical SeedFinder data"
  end

  desc "Parse Wayback Machine SeedFinder archive"
  task parse_wayback: :environment do
    archive_dir = Rails.root.join('db/data/seedfinder_archive')

    unless Dir.exist?(archive_dir)
      puts "Archive directory not found: #{archive_dir}"
      puts "Run: waybackpack seedfinder.eu/en/database/strains --from-date 2023 --to-date 202406 --output-dir #{archive_dir}"
      exit 1
    end

    # Parse archived HTML pages and extract strain data
    # This would require Nokogiri HTML parsing
    puts "Parsing archived SeedFinder pages..."
  end
end
```

---

## Fixture File Structure

```
test/
├── fixtures/
│   ├── users.yml                    # 4 users
│   ├── organizations.yml            # 1 organization
│   ├── teams.yml                    # 2 teams
│   ├── memberships.yml              # 5 memberships
│   ├── strains.yml                  # 8 scenario strains (crosses)
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
    └── (smoke tests when UI exists)
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

### strains.yml (Scenario Crosses Only)
```yaml
# Note: Base strains (GMO, Zkittlez, etc.) are imported from Kushy
# These fixtures are for custom crosses created in the scenario

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

runtz_x_wedding_cake:
  organization: exotic_genetics
  name: Runtz x Wedding Cake
  slug: runtz-x-wedding-cake
  breeder: Exotic Genetics Collective
  strain_type: hybrid
  description: >
    Dessert cross combining Runtz candy sweetness with Wedding Cake's
    vanilla notes. Expected: extreme bag appeal with balanced effects.
  lineage_text: Runtz x Wedding Cake
  genetics_type: feminized
  flowering_time_min: 56
  flowering_time_max: 63
  thc_min: 22.0
  thc_max: 28.0
  cbd_min: 0.0
  cbd_max: 1.0
  dominant_terpenes:
    - limonene
    - caryophyllene
    - linalool
  effects:
    - euphoric
    - relaxing
    - happy
  aromas:
    - candy
    - vanilla
    - sweet
    - creamy
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

  # === Scopes ===

  test "scope keepers returns keeper plants" do
    keepers = Plant.keepers
    assert keepers.all? { |p| p.status == "keeper" }
    assert_includes keepers, plants(:plant_1)
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
end
```

---

## Integration with Seeds

### db/seeds.rb (Production + Fixtures Strategy)

```ruby
# frozen_string_literal: true

puts "=== Phenow Database Seeding ==="

# Step 1: Create default trait categories and definitions
puts "\n[1/4] Creating trait categories and definitions..."
load Rails.root.join('db/seeds/traits.rb')

# Step 2: Import strain library from CSV
puts "\n[2/4] Importing strain library..."
if File.exist?(Rails.root.join('db/data/kushy_strains.csv'))
  Rake::Task['import:strains'].invoke
else
  puts "  Skipping strain import (db/data/kushy_strains.csv not found)"
  puts "  Download from: https://github.com/kushyapp/cannabis-dataset"
end

# Step 3: Load scenario fixtures for development
if Rails.env.development? || Rails.env.staging?
  puts "\n[3/4] Loading development fixtures..."
  require 'active_record/fixtures'

  fixture_files = %w[
    organizations
    users
    teams
    memberships
    projects
    project_goals
    plants
    plant_stage_transitions
    observations
    trait_values
    selections
    comments
    tags
    taggings
  ]

  ActiveRecord::FixtureSet.create_fixtures(
    Rails.root.join('test/fixtures'),
    fixture_files
  )
end

# Step 4: Summary
puts "\n[4/4] Seeding complete!"
puts "  - Users: #{User.count}"
puts "  - Organizations: #{Organization.count}"
puts "  - Teams: #{Team.count}"
puts "  - Strains: #{Strain.count}"
puts "  - Trait Categories: #{TraitCategory.count}"
puts "  - Trait Definitions: #{TraitDefinition.count}"
puts "  - Projects: #{Project.count}"
puts "  - Plants: #{Plant.count}"
puts "\n=== Ready for go-live! ==="
```

---

## Implementation Timeline (Go-Live Next Week)

### Day 1-2: Data Preparation
- [ ] Download Kushy CSV from GitHub
- [ ] Create db/data/ directory structure
- [ ] Write import rake tasks
- [ ] Test strain import locally

### Day 3: Minitest Setup
- [ ] Remove RSpec/FactoryBot from Gemfile
- [ ] Remove spec/ directory
- [ ] Configure test_helper.rb for Minitest
- [ ] Create test directory structure

### Day 4: Fixtures Creation
- [ ] Create all 20 fixture files
- [ ] Verify referential integrity
- [ ] Test fixture loading

### Day 5: Model Tests
- [ ] Generate all 18 model test files
- [ ] Write validation tests
- [ ] Write association tests
- [ ] Write scope tests

### Day 6: Integration
- [ ] Update seeds.rb with import + fixtures
- [ ] Run full `rails db:seed`
- [ ] Verify all data loads correctly
- [ ] Run `rails test` - all green

### Day 7: Final Verification
- [ ] Manual testing with real data
- [ ] Document any issues
- [ ] Ready for go-live!

---

## Success Criteria

- [ ] 2,000+ strains imported from Kushy dataset
- [ ] All RSpec/FactoryBot references removed
- [ ] 20 fixture files with realistic scenario data
- [ ] 18 model test files with comprehensive coverage
- [ ] All tests green (`rails test`)
- [ ] `rails db:seed` loads production + development data
- [ ] Development environment has real strain library
- [ ] CI pipeline runs tests successfully

---

## Resources

### Data Sources
- [Kushy Cannabis Dataset](https://github.com/kushyapp/cannabis-dataset) - Primary import
- [SeedRadar](https://seedradar.net/) - SeedFinder archive project
- [Mendeley Cannabis Research](https://data.mendeley.com/datasets/6zwcgrttkp/1) - Research data
- [Kaggle Leafly Dataset](https://www.kaggle.com/datasets/kingburrito666/cannabis-strains)
- [The Cannabis API](https://the-cannabis-api.vercel.app/)
- [Leafly Strain Database](https://www.leafly.com/strains)

### Historical Archives
- [Wayback Machine](https://web.archive.org/) - SeedFinder archives
- [waybackpack](https://github.com/jsvine/waybackpack) - Wayback download tool

### Rails Testing
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Fixtures Guide](https://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures)
