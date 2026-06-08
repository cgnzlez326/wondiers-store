namespace :tenants do
  desc "Create a new tenant with schema and seed data"
  task :create, [ :name, :domain ] => :environment do |_t, args|
    name = args[:name]
    domain = args[:domain]

    unless name && domain
      puts "Usage: rails tenants:create['Tenant Name','tenant.example.com']"
      exit 1
    end

    # Strip TLD to derive the schema name (e.g. "wondiers.com" -> "wondiers")
    schema_name = domain.split(".").first

    # Create the Tenant record in the public schema
    tenant = Tenant.create!(
      name: name,
      domain: domain,
      schema_name: schema_name
    )

    # Create the PostgreSQL schema and run migrations + seed within it
    Apartment::Tenant.create(schema_name)

    puts "Tenant '#{name}' created at domain '#{domain}' with schema '#{schema_name}'"
  end

  desc "List all tenants"
  task list: :environment do
    tenants = Tenant.order(:id)
    header = "ID | Name | Domain | Schema | Status | Created"
    puts header
    puts "-" * header.length
    tenants.each do |t|
      puts [ t.id, t.name, t.domain, t.schema_name, t.status, t.created_at.strftime("%Y-%m-%d") ].join(" | ")
    end
  end

  desc "Drop a tenant schema and delete its record — REQUIRES CONFIRMATION"
  task :drop, [ :domain ] => :environment do |_t, args|
    domain = args[:domain]

    unless domain
      puts "Usage: rails tenants:drop['tenant.example.com']"
      exit 1
    end

    tenant = Tenant.find_by!(domain: domain)

    puts ""
    puts "╔══════════════════════════════════════════════════════════════╗"
    puts "║  DESTRUCTIVE COMMAND — THIS CANNOT BE UNDONE                 ║"
    puts "╠══════════════════════════════════════════════════════════════╣"
    puts "║  Tenant : #{tenant.name.ljust(52)}║"
    puts "║  Domain : #{tenant.domain.ljust(52)}║"
    puts "║  Schema : #{tenant.schema_name.ljust(52)}║"
    puts "║  Status : #{tenant.status.to_s.ljust(52)}║"
    puts "╠══════════════════════════════════════════════════════════════╣"
    puts "║  ALL data for this tenant will be permanently destroyed:     ║"
    puts "║  products, orders, customers, inventory, payments, etc.      ║"
    puts "╚══════════════════════════════════════════════════════════════╝"
    puts ""
    print "Type the domain '#{tenant.domain}' to confirm: "
    confirm = $stdin.gets.chomp

    unless confirm == tenant.domain
      puts "Confirmation did not match. Aborted."
      exit 1
    end

    # Drop the PostgreSQL schema
    Apartment::Tenant.drop(tenant.schema_name)

    # Delete the Tenant record
    tenant.destroy!

    puts "Tenant '#{tenant.name}' (domain: #{domain}, schema: #{tenant.schema_name}) has been dropped."
  end
end
