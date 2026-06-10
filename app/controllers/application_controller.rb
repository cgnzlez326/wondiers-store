class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :detect_tenant

  private

  def detect_tenant
    return if request.path == "/up"

    identifier = resolve_tenant_identifier

    # Look up the Tenant record in the public schema BEFORE Apartment switches
    tenant = Tenant.active.find_by(schema_name: identifier) if identifier

    if tenant
      Apartment::Tenant.switch!(tenant.schema_name)
    else
      render plain: "Tenant not found", status: :not_found
    end
  end

  def resolve_tenant_identifier
    # 1. X-Tenant header (sent by Next.js storefront) — always takes priority
    return request.headers["X-Tenant"] if request.headers["X-Tenant"].present?

    # 2. Local development: localhost without header → use first active tenant
    if request.host == "localhost"
      return Tenant.active.first&.schema_name
    end

    # 3. Production: extract from request domain (e.g. "wondiers.com" -> "wondiers")
    request.host.split(".").first
  end
end
