# wondiers-store — Rails 8.1 + Spree e-commerce

## Stack

- **Ruby** 3.4.9, **Rails** 8.1, **PostgreSQL** (all environments)
- **Spree** 5.4+ (headless API backend, no built-in HTML storefront)
- **Storefront** at `/wondiers/storefront/` (separate SPA repo, e.g. Next.js/Remix)
- **Devise** auth for `Spree::User` (customers) and `Spree::AdminUser` (admins)
- **Hotwire** (Turbo + Stimulus), **importmaps** (no Node/Webpack) — used only for admin
- **Solid Queue / Solid Cache / Solid Cable** — all backed by PostgreSQL
- **Kamal** for Docker-based deployment

## Setup

```sh
bin/setup               # bundle install + db:prepare, then starts dev server
bin/dev                 # foreman start via Procfile.dev (admin CSS watch + rails s on :3000)
```

## Development

| Command | What |
|---|---|
| `bin/rails s -p 3000` | Start server only |
| `bin/rails c` | Console |
| `bin/rails db:migrate` | Migrate dev DB |
| `bin/dev` | Foreman: admin CSS watcher + server (use this) |

## Testing

```sh
bin/rails test              # All tests (Minitest, test/ directory)
bin/rails test test/models/spree/...  # Single file
bin/rails test:system       # System tests (Capybara + Selenium)
bin/rails db:test:prepare   # Before first test run if DB isn't ready
```

- Fixtures in `test/fixtures/` (including `spree/` subdirectory)
- Tests use `parallelize(workers: :number_of_processors)`
- Spree model tests go in `test/models/spree/`

## CI (GitHub Actions)

Defined in `.github/workflows/ci.yml`. Runs in order:
1. `bin/brakeman --no-pager`
2. `bin/bundler-audit`
3. `bin/importmap audit`
4. `bin/rubocop -f github`
5. `bin/rails db:test:prepare test`
6. `bin/rails db:test:prepare test:system`

Local equivalent: `bin/ci` (runs setup → rubocop → security audits → test → seeds)

## Linting & Security

```sh
bin/rubocop                 # Ruby style (rubocop-rails-omakase)
bin/brakeman --no-pager     # Rails security scan
bin/bundler-audit           # Gem vulnerability audit
bin/importmap audit         # JS dependency audit
```

## Spree customization

- Mounted at root via `mount Spree::Core::Engine, at: '/'` (config/routes.rb) — API + admin only, no HTML storefront
- Decorators: any `*_decorator*.rb` file under `app/` is auto-loaded
- Spree config in `config/initializers/spree.rb`
- Custom models go under `app/models/spree/` (e.g. `Spree::User`, `Spree::AdminUser`)
- Authentication helpers in `lib/spree/authentication_helpers.rb`
- Seeds: `Spree::Core::Engine.load_seed` runs Spree default seed data
- Admin CSS watched via `bin/rails spree:admin:tailwindcss:watch`

## Deployment (Kamal)

- Config: `config/deploy.yml` and `.kamal/secrets`
- Dockerfile at root (multi-stage, jemalloc, Thruster)
- `bin/kamal` alias commands: `console`, `shell`, `logs`, `dbc`
- Production DB uses separate databases for primary/cache/queue/cable (all PostgreSQL)

## Storefront (headless SPA)

Spree 5 is API-only — no built-in HTML storefront. The storefront lives in a separate repo at `/wondiers/storefront/` and consumes Spree's Storefront API (`/api/v3/store/*`).

### Development

Run the Rails API server (port 3000) and the storefront dev server (port 3001 or similar) side by side:

```sh
bin/dev                     # Rails API on :3000
# In another terminal:
cd /wondiers/storefront && npm run dev   # Storefront SPA
```

### Deployment

Two separate deployments:
1. **Backend** — this repo: `bin/kamal deploy`
2. **Storefront** — deploy via the storefront repo's own pipeline (Vercel, Netlify, Kamal, etc.)

### Configuration

- Set the frontend URL as an allowed origin in Spree for CORS
- Storefront uses `/api/v3/store/*` for products, cart, checkout, auth
- Auth flows use Devise tokens / JWT returned by the Spree API
