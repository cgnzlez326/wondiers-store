Apartment.configure do |config|
  # Models that live in the public (shared) schema and are NOT scoped to tenants
  config.excluded_models = [ "Tenant" ]

  # Schemas that are always available in the search path (shared across all tenants)
  config.persistent_schemas = [ "public" ]

  # Rails schema format (db/schema.rb, not SQL structure.sql)
  config.database_schema_file = "db/schema.rb"

  # Seed data loaded into each new tenant schema after creation
  config.seed_after_create = proc { Spree::Core::Engine.load_seed }
end
