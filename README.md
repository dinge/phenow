# Phenow

A smart, simple, distributed cannabis phenohunting tool.

## Overview

Phenow helps cultivators and breeders track and evaluate cannabis phenotypes through structured observations, photo documentation, and collaborative decision-making.

### Key Features

- **Project Management**: Organize phenohunts and breeding projects with clear goals
- **Plant Tracking**: Track individual plants from seed to selection
- **Trait Evaluation**: Score plants using customizable trait definitions
- **Photo Documentation**: Visual records with stage tagging
- **Lab Test Integration**: Store and compare COA results
- **Selection Workflow**: Document decisions with reasoning
- **Team Collaboration**: Share projects and compare observations
- **Mobile-First**: Designed for data entry in the grow room

## Tech Stack

- **Ruby**: 3.3+
- **Rails**: 8.0+
- **Database**: PostgreSQL 16+
- **Frontend**: Tailwind CSS 4, Turbo, Stimulus
- **Authentication**: Devise
- **Authorization**: Pundit
- **File Storage**: ActiveStorage
- **Background Jobs**: Solid Queue (Rails 8 default)
- **iOS App**: Hotwire Native (planned)

## Development Setup

### Prerequisites

- Ruby 3.3.6+
- PostgreSQL 16+
- Node.js 20+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd phenow

# Install dependencies
bundle install
yarn install

# Setup database
rails db:create db:migrate db:seed

# Start the server
bin/dev
```

### Running Tests

```bash
bundle exec rspec
```

## Documentation

See the [docs/](docs/) directory for detailed documentation:

- [Domain Model](docs/DOMAIN_MODEL.md) - Complete domain model, glossary, and architecture

## License

Proprietary - All rights reserved.
