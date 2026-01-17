# Phenow - Domain Model & Architecture

> A smart, simple, distributed cannabis phenohunting tool

## Vision

Phenow is designed to be the **best and simplest tool** for phenohunting and breeding projects. It manages complex data while maintaining **joy of use** and **correctness** as primary values.

### Core Principles

1. **KISS** - Keep It Simple, Stupid. Every feature must earn its place.
2. **Mobile-First** - Data entry happens in the grow room, not at a desk.
3. **Distributed** - Teams run their own servers; data stays where they want it.
4. **Offline-Ready** - The iOS app works without connectivity (future).
5. **Collaborative** - Teams share observations, compare notes, make decisions together.

---

## Glossary of Terms

### Genetics & Plants

| Term | Definition |
|------|------------|
| **Strain** | A named cannabis variety with defined genetics (e.g., "OG Kush", "Blue Dream") |
| **Genotype** | The genetic makeup of a plant - the DNA instructions |
| **Phenotype** | The observable expression of a genotype - how traits actually manifest |
| **Pheno** | Short for phenotype; a specific individual plant's expression |
| **Cross** | The offspring genetics from breeding two parent strains (e.g., "GMO x Zkittlez") |
| **F1** | First filial generation - direct offspring of two distinct parent strains |
| **F2** | Second filial generation - offspring from crossing two F1 plants |
| **S1** | Selfed first generation - offspring from self-pollinating a female |
| **BX** | Backcross - crossing offspring back to a parent to reinforce traits |
| **IBL** | Inbred Line - highly stable genetics from multiple generations of inbreeding |
| **Landrace** | Original wild strains from specific geographic regions |
| **Clone** | Genetic copy taken from a mother plant |
| **Mother** | A kept female plant used for taking clones |
| **Father** | A male plant selected for breeding |

### Phenohunting Process

| Term | Definition |
|------|------------|
| **Phenohunt** | The process of growing multiple seeds to find exceptional individuals |
| **Keeper** | A plant selected to be preserved (as mother/clone) |
| **Cull** | To remove/discard a plant from the hunt |
| **Selection** | The decision to keep, cull, or use a plant for breeding |
| **Run** | A single growing cycle from seed/clone to harvest |
| **Pheno Number** | Identifier for individual plants (e.g., "GMO x Zkittlez #7") |

### Growth Stages

| Stage | Description |
|-------|-------------|
| **Germination** | Seed sprouting (0-7 days) |
| **Seedling** | Early growth with cotyledons and first true leaves (1-3 weeks) |
| **Vegetative** | Main growth phase before flowering (3-16 weeks) |
| **Pre-Flower** | Transition showing sex, stretch begins (1-2 weeks) |
| **Flowering** | Bud development phase (7-12 weeks) |
| **Flush** | Final phase, nutrients cleared (1-2 weeks) |
| **Harvest** | Plant cut down |
| **Drying** | Initial moisture removal (7-14 days) |
| **Curing** | Long-term storage for quality development (2+ weeks) |
| **Testing** | Lab analysis and personal evaluation |

### Traits & Evaluation

| Term | Definition |
|------|------------|
| **Trait** | A measurable or observable characteristic |
| **Vigor** | Overall health and growth speed |
| **Structure** | Plant architecture (bushy, stretchy, branching pattern) |
| **Internode** | Space between branch nodes (tight vs. stretchy) |
| **Trichome** | Resin glands that contain cannabinoids and terpenes |
| **Terps/Terpenes** | Aromatic compounds that define smell and taste |
| **Nose** | The smell profile of a plant |
| **Bag Appeal** | Visual attractiveness of dried/cured flower |
| **Frost** | Trichome coverage density |
| **Stack** | How buds form along branches |

### Lab & Testing

| Term | Definition |
|------|------------|
| **COA** | Certificate of Analysis - lab test results document |
| **Cannabinoid Profile** | THC, CBD, CBG, CBN and other cannabinoid percentages |
| **Terpene Profile** | Individual terpene percentages |
| **Total THC** | THCa × 0.877 + THC (accounts for decarboxylation) |
| **Potency** | Overall strength, usually referring to THC content |

---

## Domain Model

### Entity Relationship Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ORGANIZATION                                    │
│  (Server instance - groups can run their own)                               │
└─────────────────────────────────────────────────────────────────────────────┘
           │
           │ has many
           ▼
┌─────────────────────┐         ┌─────────────────────┐
│       TEAMS         │◄────────│    MEMBERSHIPS      │────────►┌──────────┐
│  (Working groups)   │         │  (User-Team-Role)   │         │  USERS   │
└─────────────────────┘         └─────────────────────┘         └──────────┘
           │
           │ has many
           ▼
┌─────────────────────┐         ┌─────────────────────┐
│      PROJECTS       │────────►│   PROJECT GOALS     │
│  (Phenohunt/Breed)  │         │ (What we're seeking)│
└─────────────────────┘         └─────────────────────┘
           │
           │ has many
           ▼
┌─────────────────────┐         ┌─────────────────────┐
│       PLANTS        │────────►│    OBSERVATIONS     │
│  (Individual phenos)│         │  (Point-in-time)    │
└─────────────────────┘         └─────────────────────┘
           │                               │
           │                               │ has many
           │                               ▼
           │                    ┌─────────────────────┐
           │                    │    TRAIT VALUES     │
           │                    │  (Recorded scores)  │
           │                    └─────────────────────┘
           │                               │
           │                               │ belongs to
           │                               ▼
           │                    ┌─────────────────────┐
           │                    │  TRAIT DEFINITIONS  │◄───┐
           │                    │  (What to measure)  │    │
           │                    └─────────────────────┘    │
           │                               │               │
           │                               │ belongs to    │
           │                               ▼               │
           │                    ┌─────────────────────┐    │
           │                    │  TRAIT CATEGORIES   │────┘
           │                    │  (Groupings)        │
           │                    └─────────────────────┘
           │
           ├────────►┌─────────────────────┐
           │         │       PHOTOS        │
           │         │  (Visual records)   │
           │         └─────────────────────┘
           │
           ├────────►┌─────────────────────┐
           │         │      LAB TESTS      │
           │         │  (COA results)      │
           │         └─────────────────────┘
           │
           └────────►┌─────────────────────┐
                     │     SELECTIONS      │
                     │  (Keep/Cull/Breed)  │
                     └─────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                           STRAIN LIBRARY                                     │
└─────────────────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────┐         ┌─────────────────────┐
│       STRAINS       │◄───────►│      LINEAGE        │
│  (Genetics library) │         │  (Parent links)     │
└─────────────────────┘         └─────────────────────┘
```

---

## ActiveRecord Models

### Core Models

#### User
Authentication and identity.

```ruby
# users
- id: bigint (PK)
- email: string (unique, not null)
- encrypted_password: string (not null)
- name: string (not null)
- avatar_url: string
- timezone: string (default: 'UTC')
- preferences: jsonb (default: {})
- confirmed_at: datetime
- created_at: datetime
- updated_at: datetime

# Devise fields: reset_password_token, reset_password_sent_at,
# remember_created_at, confirmation_token, unconfirmed_email, etc.
```

#### Organization
Server instance configuration.

```ruby
# organizations
- id: bigint (PK)
- name: string (not null)
- slug: string (unique, not null)
- description: text
- server_url: string  # For federation (future)
- settings: jsonb (default: {})
- created_at: datetime
- updated_at: datetime
```

#### Team
Working group within an organization.

```ruby
# teams
- id: bigint (PK)
- organization_id: bigint (FK, not null)
- name: string (not null)
- slug: string (not null)  # unique within org
- description: text
- settings: jsonb (default: {})
- created_at: datetime
- updated_at: datetime

# unique index on [organization_id, slug]
```

#### Membership
User-Team relationship with role.

```ruby
# memberships
- id: bigint (PK)
- user_id: bigint (FK, not null)
- team_id: bigint (FK, not null)
- role: string (not null, default: 'member')  # owner, admin, member, viewer
- created_at: datetime
- updated_at: datetime

# unique index on [user_id, team_id]
```

### Genetics Models

#### Strain
Genetic variety definition.

```ruby
# strains
- id: bigint (PK)
- organization_id: bigint (FK, not null)
- name: string (not null)
- slug: string (not null)
- breeder: string  # Original breeder/seedbank
- strain_type: string  # indica, sativa, hybrid, ruderalis
- description: text
- lineage_text: string  # Free text lineage (e.g., "GMO x Zkittlez")
- genetics_type: string  # regular, feminized, autoflower
- flowering_time_min: integer  # days
- flowering_time_max: integer  # days
- thc_min: decimal(5,2)
- thc_max: decimal(5,2)
- cbd_min: decimal(5,2)
- cbd_max: decimal(5,2)
- dominant_terpenes: string[]  # array of terpene names
- effects: string[]  # array: relaxing, uplifting, creative, etc.
- aromas: string[]  # array: earthy, citrus, diesel, etc.
- public: boolean (default: false)  # Shared to community
- verified: boolean (default: false)
- metadata: jsonb (default: {})
- created_at: datetime
- updated_at: datetime

# unique index on [organization_id, slug]
```

#### StrainLineage
Parent-child relationships between strains.

```ruby
# strain_lineages
- id: bigint (PK)
- child_strain_id: bigint (FK, not null)
- parent_strain_id: bigint (FK, not null)
- parent_role: string (not null)  # mother, father, unknown
- created_at: datetime

# unique index on [child_strain_id, parent_strain_id]
```

### Project Models

#### Project
A phenohunt or breeding project.

```ruby
# projects
- id: bigint (PK)
- team_id: bigint (FK, not null)
- strain_id: bigint (FK)  # The genetics being hunted
- name: string (not null)
- slug: string (not null)
- project_type: string (not null)  # phenohunt, breeding, preservation
- status: string (not null, default: 'active')  # planning, active, completed, archived
- description: text
- start_date: date
- target_end_date: date
- actual_end_date: date
- seed_count: integer  # How many seeds started
- settings: jsonb (default: {})
- created_at: datetime
- updated_at: datetime

# unique index on [team_id, slug]
```

#### ProjectGoal
What we're looking for in this hunt.

```ruby
# project_goals
- id: bigint (PK)
- project_id: bigint (FK, not null)
- title: string (not null)
- description: text
- priority: integer (default: 0)  # Higher = more important
- target_trait_id: bigint (FK)  # Optional link to trait
- target_value: string  # What we're aiming for
- achieved: boolean (default: false)
- created_at: datetime
- updated_at: datetime
```

### Plant Models

#### Plant
Individual specimen being evaluated.

```ruby
# plants
- id: bigint (PK)
- project_id: bigint (FK, not null)
- strain_id: bigint (FK)
- identifier: string (not null)  # e.g., "#1", "A", "GMO-7"
- name: string  # Optional nickname
- source_type: string (not null)  # seed, clone
- source_plant_id: bigint (FK)  # If clone, link to mother
- sex: string  # unknown, female, male, hermaphrodite
- current_stage: string (default: 'germination')
- status: string (default: 'active')  # active, keeper, culled, harvested, archived
- germination_date: date
- flip_date: date  # When switched to flower
- harvest_date: date
- notes: text
- metadata: jsonb (default: {})
- created_at: datetime
- updated_at: datetime

# unique index on [project_id, identifier]
```

#### PlantStageTransition
Track when plants move between stages.

```ruby
# plant_stage_transitions
- id: bigint (PK)
- plant_id: bigint (FK, not null)
- from_stage: string
- to_stage: string (not null)
- transitioned_at: datetime (not null)
- notes: text
- recorded_by_id: bigint (FK)  # User
- created_at: datetime
```

### Observation & Traits Models

#### TraitCategory
Grouping of related traits.

```ruby
# trait_categories
- id: bigint (PK)
- organization_id: bigint (FK)  # null = system default
- name: string (not null)
- slug: string (not null)
- description: text
- display_order: integer (default: 0)
- icon: string
- created_at: datetime
- updated_at: datetime
```

#### TraitDefinition
What traits can be measured.

```ruby
# trait_definitions
- id: bigint (PK)
- organization_id: bigint (FK)  # null = system default
- trait_category_id: bigint (FK, not null)
- name: string (not null)
- slug: string (not null)
- description: text
- data_type: string (not null)  # numeric, scale, select, boolean, text
- unit: string  # cm, g, days, etc.
- min_value: decimal
- max_value: decimal
- scale_labels: jsonb  # For scale type: {1: "Poor", 5: "Average", 10: "Excellent"}
- options: string[]  # For select type
- applicable_stages: string[]  # Which stages this trait applies to
- display_order: integer (default: 0)
- system_default: boolean (default: false)
- created_at: datetime
- updated_at: datetime
```

#### Observation
A point-in-time observation session.

```ruby
# observations
- id: bigint (PK)
- plant_id: bigint (FK, not null)
- observed_by_id: bigint (FK, not null)  # User
- observed_at: datetime (not null)
- stage: string  # Stage at time of observation
- week_number: integer  # Week of veg/flower
- overall_score: decimal(3,1)  # 1-10 quick rating
- notes: text
- created_at: datetime
- updated_at: datetime
```

#### TraitValue
Individual trait measurement within an observation.

```ruby
# trait_values
- id: bigint (PK)
- observation_id: bigint (FK, not null)
- trait_definition_id: bigint (FK, not null)
- numeric_value: decimal
- text_value: string
- boolean_value: boolean
- notes: text
- created_at: datetime
- updated_at: datetime
```

### Media Models

#### Photo
Visual documentation (uses ActiveStorage).

```ruby
# photos
- id: bigint (PK)
- photographable_type: string (not null)  # Plant, Observation, LabTest
- photographable_id: bigint (not null)
- taken_by_id: bigint (FK)  # User
- taken_at: datetime
- caption: text
- photo_type: string  # whole_plant, bud, trichome, leaf, environment
- stage: string  # Stage when taken
- is_primary: boolean (default: false)
- metadata: jsonb (default: {})  # EXIF, dimensions, etc.
- created_at: datetime
- updated_at: datetime

# ActiveStorage attachment: has_one_attached :image
```

### Lab & Testing Models

#### LabTest
External laboratory test results.

```ruby
# lab_tests
- id: bigint (PK)
- plant_id: bigint (FK, not null)
- lab_name: string
- test_date: date
- sample_type: string  # flower, concentrate, edible
- batch_number: string
- coa_url: string  # Link to certificate
- total_thc: decimal(5,2)
- total_cbd: decimal(5,2)
- total_cannabinoids: decimal(5,2)
- total_terpenes: decimal(5,2)
- cannabinoid_profile: jsonb  # {thca: 22.5, thc: 0.8, cbda: 0.1, ...}
- terpene_profile: jsonb  # {myrcene: 1.2, limonene: 0.8, ...}
- contaminants: jsonb  # Pesticides, heavy metals, etc.
- passed: boolean
- notes: text
- metadata: jsonb (default: {})
- created_at: datetime
- updated_at: datetime

# ActiveStorage attachment: has_one_attached :coa_document
```

### Selection & Decision Models

#### Selection
Decision record for a plant.

```ruby
# selections
- id: bigint (PK)
- plant_id: bigint (FK, not null)
- selected_by_id: bigint (FK, not null)  # User
- decision: string (not null)  # keep, cull, breeding_mother, breeding_father, further_evaluation
- selected_at: datetime (not null)
- reasoning: text (not null)  # Why this decision?
- score: decimal(3,1)  # Final score 1-10
- standout_traits: string[]  # What made it special
- concerns: string[]  # What held it back
- created_at: datetime
- updated_at: datetime
```

### Collaboration Models

#### Comment
Discussion on any entity.

```ruby
# comments
- id: bigint (PK)
- commentable_type: string (not null)
- commentable_id: bigint (not null)
- user_id: bigint (FK, not null)
- parent_comment_id: bigint (FK)  # For threading
- body: text (not null)
- created_at: datetime
- updated_at: datetime
```

#### Tag
Flexible tagging system.

```ruby
# tags
- id: bigint (PK)
- organization_id: bigint (FK, not null)
- name: string (not null)
- slug: string (not null)
- color: string  # Hex color for display
- created_at: datetime
- updated_at: datetime

# unique index on [organization_id, slug]
```

#### Tagging
Polymorphic tag assignments.

```ruby
# taggings
- id: bigint (PK)
- tag_id: bigint (FK, not null)
- taggable_type: string (not null)
- taggable_id: bigint (not null)
- created_at: datetime

# unique index on [tag_id, taggable_type, taggable_id]
```

---

## Default Trait Categories & Definitions

### System Default Traits

```yaml
Vigor & Health:
  - Overall Vigor: scale 1-10
  - Growth Speed: scale 1-10 (slow to fast)
  - Root Health: scale 1-10
  - Pest Resistance: scale 1-10
  - Disease Resistance: scale 1-10
  - Stress Recovery: scale 1-10

Structure:
  - Height: numeric (cm)
  - Spread/Width: numeric (cm)
  - Internode Spacing: select (tight, medium, stretchy)
  - Branching Pattern: select (minimal, moderate, heavy)
  - Stem Thickness: select (thin, medium, thick)
  - Leaf Size: select (small, medium, large)
  - Leaf Shape: select (narrow/sativa, broad/indica, hybrid)

Flowering:
  - Days to Show Sex: numeric (days)
  - Stretch Amount: select (low <50%, medium 50-100%, high >100%)
  - Flowering Time: numeric (days from flip)
  - Bud Structure: select (airy, moderate, dense, rock-hard)
  - Bud Size: select (small, medium, large, chunky)
  - Calyx-to-Leaf Ratio: scale 1-10
  - Foxtailing: boolean

Resin & Trichomes:
  - Trichome Coverage: scale 1-10 (frost level)
  - Trichome Head Size: select (small, medium, large)
  - Trichome Color: select (clear, cloudy, amber, mixed)
  - Stickiness: scale 1-10
  - Resin Production: scale 1-10

Aroma & Flavor:
  - Aroma Intensity: scale 1-10
  - Primary Aroma: select (earthy, citrus, sweet, diesel, floral, pine, spicy, cheese, berry, tropical, skunky, chemical)
  - Secondary Aroma: select (same options)
  - Flavor Match to Aroma: scale 1-10
  - Smoothness: scale 1-10

Appearance:
  - Bag Appeal: scale 1-10
  - Color: select (green, purple, pink, orange, multicolor)
  - Pistil Color: select (white, orange, red, pink)
  - Sugar Leaf Frost: scale 1-10
  - Trim Ease: scale 1-10

Harvest & Yield:
  - Wet Weight: numeric (g)
  - Dry Weight: numeric (g)
  - Yield Rating: scale 1-10
  - Drying Time: numeric (days)
  - Cure Quality: scale 1-10

Effects (Post-Harvest):
  - Potency: scale 1-10
  - Onset Speed: select (instant, gradual, slow)
  - Duration: select (short <1hr, medium 1-2hr, long 2-4hr, very long >4hr)
  - Primary Effect: select (relaxing, uplifting, euphoric, creative, focused, sedating, energizing)
  - Body Effect: scale 1-10
  - Head Effect: scale 1-10
  - Medical Potential: text
```

---

## Core Processes & Workflows

### 1. Start a Phenohunt Project

```
1. Create Project
   - Name the hunt
   - Select or create the strain/cross
   - Set goals (what are you looking for?)
   - Enter seed count

2. Plant Setup
   - Create plant entries (batch or individual)
   - Auto-generate identifiers (#1, #2, ... or A, B, C, ...)
   - Set germination date

3. Begin Tracking
   - Project status → active
```

### 2. Daily/Weekly Observations

```
1. Quick Entry Mode (Mobile)
   - Select plant(s)
   - Swipe through quick ratings
   - Snap photos
   - Voice note (transcribed)

2. Detailed Observation
   - Select stage-appropriate traits
   - Enter measurements
   - Score traits
   - Add notes
   - Attach photos

3. Batch Operations
   - "All plants are healthy today" - quick batch note
   - Stage transitions for multiple plants
```

### 3. Selection Process

```
1. Comparison View
   - Side-by-side photos
   - Trait comparison table
   - Score summaries

2. Make Selection
   - Choose decision: keep/cull/evaluate more
   - Document reasoning (required!)
   - Note standout traits
   - Note concerns

3. Update Plant Status
   - Keeper → preserve as mother
   - Cull → archive with learnings
   - Breeding stock → mark for future crosses
```

### 4. Project Completion

```
1. Final Selections Made
   - All plants have decisions
   - Keepers documented

2. Project Summary
   - Auto-generated report
   - Statistics (keeper rate, trait distributions)
   - Key learnings

3. Archive or Continue
   - Archive completed hunt
   - Or continue to breeding phase
```

---

## MVP Scope (Phase 1)

### In MVP

- [x] User authentication (Devise)
- [x] Single organization (multi-org later)
- [x] Teams with basic roles
- [x] Strain library (basic fields)
- [x] Projects (phenohunt type only)
- [x] Plants with identifiers
- [x] Simple observations (notes + overall score)
- [x] Photos (ActiveStorage)
- [x] Basic selections (keep/cull + reasoning)
- [x] Mobile-responsive Tailwind UI
- [x] Turbo + Stimulus for interactivity
- [x] PostgreSQL database

### Phase 2

- [ ] Structured traits system
- [ ] Lab test integration
- [ ] Comparison views
- [ ] Family tree visualization
- [ ] Export/reports (PDF, CSV)
- [ ] API for mobile app

### Phase 3

- [ ] iOS app (Hotwire Native wrapper)
- [ ] Offline data entry
- [ ] Local image storage
- [ ] Push notifications

### Phase 4

- [ ] Local AI image analysis
- [ ] Trait prediction
- [ ] Cross-server federation
- [ ] Community strain database
- [ ] Breeding project type
- [ ] Genetic cross planning

---

## Technical Architecture

### Stack

- **Ruby**: 3.3+
- **Rails**: 8.0+
- **Database**: PostgreSQL 16+
- **Frontend**: Tailwind CSS 4, Turbo, Stimulus
- **File Storage**: ActiveStorage (local dev, S3 production)
- **Authentication**: Devise
- **Authorization**: Pundit
- **Background Jobs**: Solid Queue (Rails 8 default)
- **Caching**: Solid Cache (Rails 8 default)
- **iOS**: Hotwire Native

### Database Indexes (Key)

```ruby
# Performance-critical indexes
add_index :plants, [:project_id, :status]
add_index :plants, [:project_id, :current_stage]
add_index :observations, [:plant_id, :observed_at]
add_index :trait_values, [:observation_id, :trait_definition_id]
add_index :photos, [:photographable_type, :photographable_id]
add_index :selections, [:plant_id, :decision]
```

### API Design (Future)

RESTful JSON API for mobile app:
- Versioned: `/api/v1/`
- Token authentication (Devise tokens or JWT)
- Offline sync support with timestamps
- Image upload with presigned URLs

---

## Sources & References

Research and inspiration from:
- [Cannamatrix](https://www.cannamatrix.com/) - Genetic testing platform
- [StrainTree AI Platform](https://www.mmjdaily.com/article/9796019/ai-powered-cannabis-genetics-platform-with-predictive-breeding-technology-launches/)
- [BioTrack Cultivation](https://biotrack.com/solutions/cultivation/)
- [PhenoApp](https://pmc.ncbi.nlm.nih.gov/articles/PMC9813448/) - Mobile phenotyping
- [BrAPI](https://brapi.org/) - Breeding API standard
- [USDA Hemp Descriptors](https://www.ars.usda.gov/northeast-area/geneva-ny/plant-genetic-resources-unit-pgru/docs/hemp-descriptors/)
- [BMC Plant Biology - Cannabis Traits](https://bmcplantbiol.biomedcentral.com/articles/10.1186/s12870-021-03079-2)
- [FloraFlex Phenotype Guide](https://floraflex.com/default/blog/post/understanding-cannabis-genetics-and-phenotype-selection)
