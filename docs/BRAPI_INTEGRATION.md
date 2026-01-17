# BrAPI Integration Plan

> Planning document for future BrAPI v2.1 compatibility

## Overview

[BrAPI](https://brapi.org/) (Breeding API) is a standardized RESTful API specification for plant breeding data exchange. Adding BrAPI support to Phenow would enable interoperability with other breeding databases, research institutions, and tools like BMS, FieldBook, and PhenoApps.

**Status**: Planned for Phase 4
**Target Version**: BrAPI v2.1

## Why BrAPI?

1. **Data Exchange** - Share strain/phenotype data with research institutions
2. **Lab Integration** - Standard format for importing test results
3. **Tool Ecosystem** - Connect with existing breeding software
4. **Credibility** - Industry-standard compliance for serious breeders

## Endpoint Mapping

### Core Module

| BrAPI Endpoint | Phenow Model | Notes |
|----------------|--------------|-------|
| `GET /serverinfo` | - | Server metadata, supported calls |
| `GET /commoncropnames` | - | Return "Cannabis" |
| `GET /locations` | Organization | Grow locations |
| `GET /seasons` | Project | Growing seasons/runs |

### Germplasm Module

| BrAPI Endpoint | Phenow Model | Notes |
|----------------|--------------|-------|
| `GET /germplasm` | Strain | List all strains |
| `GET /germplasm/{id}` | Strain | Strain details |
| `GET /germplasm/{id}/pedigree` | StrainLineage | Parent relationships |
| `GET /germplasm/{id}/progeny` | StrainLineage | Child strains |
| `POST /search/germplasm` | Strain | Search strains |
| `GET /attributes` | - | Strain attributes (THC, CBD, etc.) |
| `GET /attributevalues` | Strain | Attribute values |

### Phenotyping Module

| BrAPI Endpoint | Phenow Model | Notes |
|----------------|--------------|-------|
| `GET /studies` | Project | Phenohunt projects |
| `GET /studies/{id}` | Project | Project details |
| `GET /observationunits` | Plant | Individual plants |
| `GET /observationunits/{id}` | Plant | Plant details |
| `GET /observations` | TraitValue | All observations |
| `GET /observations/{id}` | TraitValue | Single observation |
| `POST /observations` | TraitValue | Record new observation |
| `GET /observationvariables` | TraitDefinition | Trait definitions |
| `GET /scales` | TraitDefinition | Data types and ranges |
| `GET /methods` | - | Observation methods |
| `GET /traits` | TraitCategory | Trait categories |
| `GET /images` | Photo | Plant images |
| `POST /images` | Photo | Upload image |

## Data Type Mapping

### Phenow → BrAPI Scale Classes

| Phenow `data_type` | BrAPI `scaleClass` |
|--------------------|-------------------|
| `numeric` | `Numerical` |
| `scale` | `Ordinal` |
| `select` | `Nominal` |
| `boolean` | `Nominal` (Yes/No) |
| `text` | `Text` |

### Growth Stages → BrAPI Observation Levels

| Phenow Stage | BrAPI Level |
|--------------|-------------|
| `germination` | `plant` |
| `seedling` | `plant` |
| `vegetative` | `plant` |
| `flowering` | `plant` |
| `harvest` | `plant` |
| `testing` | `sample` |

## Implementation Plan

### Phase 1: Read-Only Endpoints
```
GET /brapi/v2/serverinfo
GET /brapi/v2/germplasm
GET /brapi/v2/germplasm/{id}
GET /brapi/v2/studies
GET /brapi/v2/observationunits
GET /brapi/v2/observations
GET /brapi/v2/observationvariables
```

### Phase 2: Search Endpoints
```
POST /brapi/v2/search/germplasm
POST /brapi/v2/search/observationunits
POST /brapi/v2/search/observations
```

### Phase 3: Write Endpoints
```
POST /brapi/v2/observations
PUT /brapi/v2/observations/{id}
POST /brapi/v2/images
```

### Phase 4: Full Compliance
- Pagination with `page` and `pageSize`
- Async search with `searchResultsDbId`
- All required metadata fields
- BrAPI test suite passing

## Technical Implementation

### Controller Structure
```ruby
# app/controllers/brapi/v2/base_controller.rb
module Brapi
  module V2
    class BaseController < ApplicationController
      skip_before_action :authenticate_user!  # Public read, auth for write

      def render_brapi(data, metadata = {})
        render json: {
          "@context" => ["https://brapi.org/jsonld/context/brapi-v2.jsonld"],
          "metadata" => brapi_metadata(metadata),
          "result" => data
        }
      end

      private

      def brapi_metadata(opts = {})
        {
          "datafiles" => [],
          "pagination" => {
            "currentPage" => opts[:page] || 0,
            "pageSize" => opts[:page_size] || 1000,
            "totalCount" => opts[:total] || 0,
            "totalPages" => opts[:total_pages] || 1
          },
          "status" => []
        }
      end
    end
  end
end
```

### Routes
```ruby
# config/routes.rb
namespace :brapi do
  namespace :v2 do
    get 'serverinfo', to: 'server#info'
    resources :germplasm, only: [:index, :show] do
      get 'pedigree', on: :member
    end
    resources :studies, only: [:index, :show]
    resources :observationunits, only: [:index, :show]
    resources :observations, only: [:index, :show, :create, :update]
    resources :observationvariables, only: [:index, :show]
  end
end
```

### Serializers
```ruby
# app/serializers/brapi/germplasm_serializer.rb
module Brapi
  class GermplasmSerializer
    def initialize(strain)
      @strain = strain
    end

    def as_json
      {
        "germplasmDbId" => @strain.id.to_s,
        "germplasmName" => @strain.name,
        "germplasmPUI" => nil,  # Permanent Unique Identifier
        "accessionNumber" => @strain.slug,
        "acquisitionDate" => @strain.created_at.iso8601,
        "biologicalStatusOfAccessionCode" => biological_status,
        "breedingMethodDbId" => nil,
        "commonCropName" => "Cannabis",
        "countryOfOriginCode" => nil,
        "defaultDisplayName" => @strain.name,
        "genus" => "Cannabis",
        "species" => "sativa",
        "subtaxa" => @strain.strain_type,
        "pedigree" => @strain.lineage_text,
        "seedSource" => @strain.breeder,
        "synonyms" => []
      }
    end

    private

    def biological_status
      case @strain.genetics_type
      when "regular" then "300"  # Breeding/research material
      when "feminized" then "500"  # Advanced/improved cultivar
      else "999"  # Other
      end
    end
  end
end
```

## Testing

### BrAPI Test Suite
Use the official [BrAPI Test Suite](https://github.com/plantbreeding/BrAPI-Validator) to validate compliance:

```bash
# Run BrAPI validator
docker run --rm -it \
  -e BASE_URL=http://localhost:3000/brapi/v2 \
  brapi/brapi-validator
```

### RSpec Tests
```ruby
# spec/requests/brapi/v2/germplasm_spec.rb
RSpec.describe "BrAPI Germplasm", type: :request do
  describe "GET /brapi/v2/germplasm" do
    it "returns germplasm list in BrAPI format" do
      create_list(:strain, 3)

      get "/brapi/v2/germplasm"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["result"]["data"].length).to eq(3)
      expect(json["metadata"]["pagination"]["totalCount"]).to eq(3)
    end
  end
end
```

## Resources

- [BrAPI Specification](https://brapi.org/specification)
- [BrAPI v2.1 OpenAPI Docs](https://app.swaggerhub.com/apis/PlantBreedingAPI/BrAPI-Phenotyping/2.1)
- [BrAPI GitHub](https://github.com/plantbreeding/BrAPI)
- [BrAPI Test Suite](https://github.com/plantbreeding/BrAPI-Validator)
- [BrAPI Community](https://brapi.org/community)

## Timeline

| Milestone | Target |
|-----------|--------|
| Phase 1: Read-Only | Phase 4 Start |
| Phase 2: Search | Phase 4 + 2 weeks |
| Phase 3: Write | Phase 4 + 4 weeks |
| Phase 4: Full Compliance | Phase 4 + 6 weeks |

## Notes

- BrAPI is designed for institutional/research use - evaluate if your users actually need it
- Consider authentication requirements for write endpoints
- Cannabis-specific terms (THC, CBD, terpenes) may need custom ontology mappings
- Federation between Phenow servers could use BrAPI as the exchange format
