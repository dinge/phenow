# CLAUDE.md - Phenow Development Guide

## Project Overview

Phenow is a distributed cannabis phenohunting tool built with Rails 8, Hotwire (Turbo + Stimulus), and Tailwind CSS. It's designed for teams to track and evaluate plant phenotypes through structured observations, photo documentation, and collaborative decision-making.

## Tech Stack

- **Ruby**: 3.3.6
- **Rails**: 8.0+
- **Database**: PostgreSQL 16+
- **Frontend**: Tailwind CSS 4, Turbo, Stimulus
- **Auth**: Devise (authentication), Pundit (authorization)
- **File Storage**: ActiveStorage
- **Background Jobs**: Solid Queue
- **iOS App**: Hotwire Native (planned)

## Project Structure

```
phenow/
├── app/
│   ├── models/          # 18 ActiveRecord models (see below)
│   ├── controllers/     # TODO: Generate controllers
│   ├── views/           # TODO: Tailwind-based responsive UI
│   └── javascript/      # Stimulus controllers
├── db/
│   ├── migrate/         # 22 migrations
│   └── seeds.rb         # Default trait categories (8) and definitions (30+)
├── docs/
│   └── DOMAIN_MODEL.md  # Complete domain model, glossary, architecture
└── config/
    └── routes.rb        # RESTful routes defined
```

## Core Models

| Model | Purpose |
|-------|---------|
| `User` | Authentication via Devise |
| `Organization` | Server instance (multi-tenancy) |
| `Team` | Working group within org |
| `Membership` | User-Team with roles (owner/admin/member/viewer) |
| `Strain` | Genetics library with lineage |
| `Project` | Phenohunt/breeding project |
| `Plant` | Individual specimen being evaluated |
| `Observation` | Point-in-time observation session |
| `TraitDefinition` | Configurable trait (numeric/scale/select/boolean) |
| `TraitValue` | Recorded measurement |
| `Photo` | Visual documentation (ActiveStorage) |
| `LabTest` | COA results (cannabinoids, terpenes) |
| `Selection` | Keep/cull decision with reasoning |

## Key Concepts

### Growth Stages
`germination → seedling → vegetative → pre_flower → flowering → flush → harvest → drying → curing → testing`

### Plant Statuses
`active`, `keeper`, `culled`, `harvested`, `archived`

### Selection Decisions
`keep`, `cull`, `breeding_mother`, `breeding_father`, `further_evaluation`

### Trait Data Types
- `numeric` - measurements with units (cm, g, days)
- `scale` - 1-10 ratings with labels
- `select` - predefined options
- `boolean` - yes/no
- `text` - free-form

## Development Commands

```bash
# Setup
bundle install
yarn install
rails db:create db:migrate db:seed

# Run development server
bin/dev

# Run tests
bundle exec rspec

# Linting
bin/rubocop
```

## Coding Conventions

### Models
- Use `frozen_string_literal: true`
- Define constants for enums (e.g., `STATUSES = %w[...].freeze`)
- Order: associations, delegations, validations, scopes, callbacks, methods
- Use FriendlyId for user-facing slugs

### Controllers
- Use Pundit for authorization (`authorize @resource`)
- Use Pagy for pagination
- Respond to both HTML and Turbo Stream formats

### Views
- Mobile-first Tailwind CSS
- Use Turbo Frames for partial page updates
- Use Stimulus for JavaScript behavior
- Keep views simple, use partials

### Testing
- RSpec with FactoryBot
- Model specs for validations and business logic
- Request specs for API endpoints
- System specs for critical workflows

## API Design

### Internal API (for iOS app)
```
/api/v1/
├── projects
├── plants
├── observations
├── photos
└── strains
```

### BrAPI Support (Planned)
See `docs/BRAPI_INTEGRATION.md` for mapping to BrAPI v2.1 specification.

## Future Phases

### Phase 2
- [ ] Structured traits UI
- [ ] Lab test integration
- [ ] Comparison views
- [ ] Family tree visualization
- [ ] Export/reports (PDF, CSV)

### Phase 3
- [ ] iOS app (Hotwire Native wrapper)
- [ ] Offline data entry
- [ ] Push notifications

### Phase 4
- [ ] Local AI image analysis
- [ ] BrAPI v2.1 endpoints
- [ ] Cross-server federation
- [ ] Breeding predictions

## Important Notes

- **Mobile-First**: Always design for phone screens first, then scale up
- **Joy of Use**: Keep UI simple and fast for grow room data entry
- **Data Integrity**: Require reasoning for selections, track all changes
- **Privacy**: Teams run their own servers, data stays local
