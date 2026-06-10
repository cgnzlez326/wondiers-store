# This migration creates the tenants table in the public schema only.
# When Apartment creates a new tenant schema and runs all migrations
# inside that schema, this migration skips itself to avoid creating
# a tenants table inside every tenant schema.
class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    return unless Apartment::Tenant.current.nil?

    create_table :tenants do |t|
      t.string :name, null: false
      t.string :domain, null: false
      t.string :schema_name, null: false
      t.string :status, default: "active"
      t.jsonb :settings, default: {}
      t.timestamps
    end

    add_index :tenants, :domain, unique: true
    add_index :tenants, :schema_name, unique: true
  end
end
