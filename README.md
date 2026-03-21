# today.bike

`today.bike` is a Rails 8 application for a bicycle shop's public website, admin operations, and customer portal.

## Stack

- Ruby `3.3.6`
- Rails `8.1`
- SQLite in production and development
- Hotwire (`turbo-rails`, `stimulus-rails`)
- Tailwind CSS
- Docker for production runtime

## Current Production Reality

- production server: Oracle Cloud VM (`217.142.238.243`)
- production URL: `https://todaybike.cyanluna.com`
- deploy path: `bin/deploy`
- registry: `ghcr.io/cyanluna-git/today-bike:latest`
- persistent app state: Docker volume mounted at `/rails/storage`
- edge stack: host `nginx` reverse proxy on `80/443` -> Docker container on `127.0.0.1:3000`

Canonical deploy runbook:

- [docs/current_deploy_runbook.md](/Users/cyanluna-pro16/dev/today.bike/docs/current_deploy_runbook.md)

Server and operations notes:

- [docs/oracle_server_info.md](/Users/cyanluna-pro16/dev/today.bike/docs/oracle_server_info.md)
- [docs/deployment_operations_review.md](/Users/cyanluna-pro16/dev/today.bike/docs/deployment_operations_review.md)

## Local Setup

Install dependencies:

```bash
bundle install
```

Prepare the database:

```bash
bin/rails db:prepare
```

Run the app locally:

```bash
bin/dev
```

Default local URL:

```text
http://127.0.0.1:3000
```

## Tests

Run the full test suite:

```bash
bundle exec rails test
```

Run a focused file:

```bash
bundle exec rails test test/controllers/portal/bicycles_controller_test.rb
```

## Deploy

`bin/deploy` builds the current local working tree, pushes the image to GHCR, pulls it on the Oracle VM, restarts the `today-bike` container behind host `nginx`, reloads nginx, and verifies HTTP `200`.

Required before deploy:

- `config/master.key`
- Docker running locally
- SSH access to the production server
- `GHCR_TOKEN` with `write:packages`

Example:

```bash
export GHCR_TOKEN=ghp_xxx
bin/deploy
```

## Notes

- `config/deploy.yml` exists for Kamal, but it is not the currently used production deploy path.
- Production Active Storage is still local-volume based unless separately reconfigured.
- Public requests should use `https://todaybike.cyanluna.com`; direct IP access is not the intended production entrypoint.
