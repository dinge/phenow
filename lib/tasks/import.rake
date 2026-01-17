# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import strains from Kushy CSV"
  task strains: :environment do
    file = Rails.root.join("db/data/kushy_strains.csv")

    unless File.exist?(file)
      puts "Error: #{file} not found"
      puts "Download from: https://github.com/kushyapp/cannabis-dataset"
      exit 1
    end

    puts "Importing strains from Kushy dataset..."
    organization = Organization.default
    imported = 0
    skipped = 0
    errors = 0

    CSV.foreach(file, headers: true) do |row|
      name = row["name"]&.strip
      next if name.blank?

      slug = row["slug"].presence || name.parameterize
      slug = slug.gsub("NULL", "").strip if slug.present?
      slug = name.parameterize if slug.blank?

      strain = Strain.find_or_initialize_by(
        slug: slug,
        organization: organization
      )

      if strain.new_record?
        thc_values = parse_cannabinoid(row["thc"])
        cbd_values = parse_cannabinoid(row["cbd"])

        strain.assign_attributes(
          name: name,
          breeder: clean_value(row["breeder"]),
          strain_type: map_strain_type(row["type"]),
          description: clean_html(row["description"]),
          lineage_text: clean_value(row["crosses"]),
          thc_min: thc_values&.first,
          thc_max: thc_values&.last,
          cbd_min: cbd_values&.first,
          cbd_max: cbd_values&.last,
          dominant_terpenes: parse_array(row["terpenes"]),
          effects: parse_effects(row["effects"]),
          aromas: parse_array(row["flavor"]),
          public: true,
          verified: false,
          metadata: build_metadata(row)
        )

        if strain.save
          imported += 1
          print "." if imported % 100 == 0
        else
          errors += 1
          puts "\nError importing '#{name}': #{strain.errors.full_messages.join(', ')}" if errors <= 10
        end
      else
        skipped += 1
      end
    end

    puts "\n"
    puts "=" * 50
    puts "Import complete!"
    puts "  Imported: #{imported}"
    puts "  Skipped:  #{skipped} (already existed)"
    puts "  Errors:   #{errors}"
    puts "  Total:    #{Strain.count} strains"
    puts "=" * 50
  end

  desc "Extract unique breeders from strains"
  task breeders: :environment do
    breeders = Strain.where.not(breeder: [nil, ""])
                     .pluck(:breeder)
                     .uniq
                     .sort

    puts "Found #{breeders.count} unique breeders:"
    breeders.first(20).each { |b| puts "  - #{b}" }
    puts "  ... and #{breeders.count - 20} more" if breeders.count > 20

    # Export to CSV for reference
    output_file = Rails.root.join("db/data/breeders.csv")
    CSV.open(output_file, "w") do |csv|
      csv << ["name", "strain_count"]
      Strain.where.not(breeder: [nil, ""])
            .group(:breeder)
            .count
            .sort_by { |_, count| -count }
            .each { |name, count| csv << [name, count] }
    end
    puts "\nExported to: #{output_file}"
  end

  desc "Show import statistics"
  task stats: :environment do
    puts "=" * 50
    puts "Strain Library Statistics"
    puts "=" * 50
    puts "Total strains:   #{Strain.count}"
    puts "Public strains:  #{Strain.public_strains.count}"
    puts "Verified:        #{Strain.verified.count}"
    puts ""
    puts "By type:"
    Strain.group(:strain_type).count.each do |type, count|
      puts "  #{type || 'unknown'}: #{count}"
    end
    puts ""
    puts "With THC data:   #{Strain.where.not(thc_max: nil).count}"
    puts "With CBD data:   #{Strain.where.not(cbd_max: nil).count}"
    puts "With terpenes:   #{Strain.where("dominant_terpenes != '{}'").count}"
    puts "With effects:    #{Strain.where("effects != '{}'").count}"
    puts "With breeder:    #{Strain.where.not(breeder: [nil, '']).count}"
    puts "=" * 50
  end

  desc "Import all data"
  task all: [:strains, :breeders, :stats] do
    puts "\nAll imports complete!"
  end
end

# Helper methods (must be at module level for rake tasks)
def map_strain_type(type)
  case type&.downcase&.strip
  when "sativa" then "sativa"
  when "indica" then "indica"
  when "hybrid" then "hybrid"
  when "ruderalis" then "ruderalis"
  else "hybrid"
  end
end

def parse_cannabinoid(value)
  return nil if value.blank? || value == "NULL" || value == "0"

  numbers = value.to_s.scan(/[\d.]+/).map(&:to_f)
  return nil if numbers.empty? || numbers.all?(&:zero?)

  numbers.length == 1 ? [numbers.first, numbers.first] : [numbers.min, numbers.max]
end

def parse_array(value)
  return [] if value.blank? || value == "NULL"

  value.to_s
       .split(",")
       .map { |v| v.strip.downcase }
       .reject(&:blank?)
       .uniq
end

def parse_effects(value)
  return [] if value.blank? || value == "NULL"

  # Kushy combines positive and negative effects
  # Filter out known negative effects
  negative = %w[dry_mouth dry_eyes paranoid dizzy anxious headache]

  parse_array(value).reject { |e| negative.include?(e.tr(" ", "_")) }
end

def clean_value(value)
  return nil if value.blank? || value == "NULL"
  value.strip
end

def clean_html(value)
  return nil if value.blank? || value == "NULL"

  # Remove HTML tags
  value.gsub(/<\/?[^>]*>/, "").strip
end

def build_metadata(row)
  metadata = {}

  # Store additional cannabinoids if present
  %w[thca thcv cbda cbdv cbn cbg cbc].each do |cannabinoid|
    val = row[cannabinoid]
    next if val.blank? || val == "NULL" || val == "0"
    metadata[cannabinoid] = val.to_f
  end

  # Store ailments/medical uses if present
  ailments = parse_array(row["ailment"])
  metadata["medical_uses"] = ailments if ailments.any?

  metadata
end
