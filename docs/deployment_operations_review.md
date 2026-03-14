# Today.bike Deployment and Operations Review

## Purpose

This document reconstructs the current deployment path of `today.bike`, compares intended architecture with actual runtime configuration, and identifies the main operations risks visible from the repository and operations docs.

Status update:

- As of `2026-03-14`, the actually used and canonical production deploy path is `bin/deploy`.
- See `docs/current_deploy_runbook.md` for the operational runbook.

Primary evidence:
- `config/deploy.yml`
- `Dockerfile`
- `bin/docker-entrypoint`
- `bin/deploy`
- `config/database.yml`
- `config/storage.yml`
- `config/environments/production.rb`
- `config/litestream.yml`
- `docs/manual_setup_guide.md`
- `docs/oracle_server_info.md`
- `docs/prod_req.md`

## Current Deployment Architecture

### Runtime shape

```text
User
  -> Cloudflare DNS / proxy
  -> today.bike
  -> single Oracle Cloud VM
  -> Docker container running Rails
  -> SQLite databases on mounted Docker volume
  -> Litestream replication to Cloudflare R2 (only if env is configured)
```

### Actual components

| Layer | Current signal | Evidence |
|---|---|---|
| App runtime | Rails app in Docker container | `Dockerfile` |
| Web serving | `./bin/thrust ./bin/rails server` | `Dockerfile` |
| Database | SQLite for primary, cache, queue, cable | `config/database.yml` |
| Persistence | `/rails/storage` mounted as Docker volume | `Dockerfile`, `config/deploy.yml` |
| Background jobs | Solid Queue in Puma process | `config/deploy.yml` |
| Realtime | Solid Cable over SQLite | `config/database.yml`, `Gemfile` |
| Backup | Litestream process started from entrypoint when replica env exists | `bin/docker-entrypoint`, `config/litestream.yml` |
| Registry | GHCR | `config/deploy.yml`, `bin/deploy` |
| Public DNS/edge | Cloudflare | `docs/manual_setup_guide.md` |
| Server | Oracle Cloud VM, Osaka, 1GB RAM | `docs/oracle_server_info.md` |

## Deployment Paths Found in Repo

### Path A: Kamal-managed deployment

Evidence:
- `config/deploy.yml`
- `Gemfile`

Observed shape:
- Service named `today-bike`
- GHCR registry credentials pulled from environment
- Volume `today-bike_storage:/rails/storage`
- `today.bike` host configured behind Kamal proxy
- Litestream replica credentials expected as secrets

Interpretation:
- This remains the intended long-term path in code configuration.
- It is not the currently used production path.

### Path B: Manual SSH deploy script

Evidence:
- `bin/deploy`

Observed shape:
- Builds local image
- Pushes to GHCR manually
- SSHes directly into server
- Stops/removes existing container
- Starts a new container with `docker run`
- Injects a minimal env set directly on the server

Interpretation:
- This is the currently used production path.
- It is the canonical runbook until a deliberate Kamal migration is completed.

### Operational implication

The repository still contains two deployment paths:
- Kamal configuration in `config/deploy.yml`
- Manual GHCR + SSH restart in `bin/deploy`

Current operational truth:

- production deploys use `bin/deploy`
- `config/deploy.yml` should be treated as future-state configuration, not current runbook

This is workable short term, but it still increases drift risk because one path can evolve without the other.

## Database and State Model

### Current production persistence model

Production uses four SQLite files under `storage/`:
- `production.sqlite3`
- `production_cache.sqlite3`
- `production_queue.sqlite3`
- `production_cable.sqlite3`

Evidence:
- `config/database.yml`

These files live on a mounted Docker volume:
- `/rails/storage`

Evidence:
- `Dockerfile`
- `config/deploy.yml`

### Backup path

`bin/docker-entrypoint` runs:
- `./bin/rails db:prepare`
- then starts Litestream replication only if `LITESTREAM_REPLICA_ENDPOINT` is set

Evidence:
- `bin/docker-entrypoint`

`config/litestream.yml` contains replica definitions for all four SQLite files.

Implication:
- Backup is conditional on runtime secrets being present.
- The codebase is prepared for SQLite replication, but successful backup depends on environment completeness, not just image contents.

## Storage Model

### Intended architecture

The PRD says:
- Active Storage + Cloudflare R2 for images
- Litestream + R2 for database backup

Evidence:
- `docs/prod_req.md`

### Actual configured runtime

Production Active Storage is still set to local disk:
- `config.active_storage.service = :local`

Evidence:
- `config/environments/production.rb`
- `config/storage.yml`

Implication:
- Service photos and uploaded images currently persist on the same mounted volume as SQLite.
- R2 appears configured for database backup only, not yet for application media storage.

## Infra Notes from Operations Docs

### Server

Current documented host:
- Oracle Cloud Infrastructure VM
- Osaka region
- 1 OCPU / 1GB RAM
- Docker installed
- Swap enabled

Evidence:
- `docs/oracle_server_info.md`

### DNS / TLS

Current intended path:
- Domain through Cloudflare
- SSL mode `Full (strict)`

Evidence:
- `docs/manual_setup_guide.md`
- `config/deploy.yml`

### Public IP caveat

The server doc says the current public IP is not reserved and may change on restart.

Evidence:
- `docs/oracle_server_info.md`

Implication:
- DNS correctness depends on manual awareness if the host IP changes.

## Mismatches and Drift

### 1. PRD says Hetzner, operations docs say Oracle

Evidence:
- `docs/prod_req.md` describes a Hetzner-based deployment path
- `docs/oracle_server_info.md` documents Oracle Cloud as the actual production server

Meaning:
- Strategy and reality have diverged.
- Architecture docs are no longer fully trustworthy unless refreshed.

### 2. PRD says R2-backed file storage, runtime is local disk

Evidence:
- `docs/prod_req.md`
- `config/environments/production.rb`
- `config/storage.yml`

Meaning:
- Media durability and horizontal portability are lower than the PRD implies.

### 3. Kamal exists, but manual deploy script remains active

Evidence:
- `config/deploy.yml`
- `bin/deploy`

Meaning:
- The canonical answer is now known: `bin/deploy`
- Drift risk still remains because Kamal config is checked in alongside the active manual path

### 4. Single-node assumptions are real, not just theoretical

Evidence:
- SQLite production config in `config/database.yml`
- single web host in `config/deploy.yml`
- Solid Queue in Puma in `config/deploy.yml`

Meaning:
- App, job queue, cable, and DB state are intentionally collapsed onto one node.
- This simplifies cost and operations, but raises blast radius.

## Severity-Ranked Risks

### High

#### 1. Media storage is local-volume only in production

Why it matters:
- If the volume is lost, service photos and blog/product media are lost even if code and registry images remain.
- The PRD may cause false confidence that image durability is already delegated to R2.

Evidence:
- `config/environments/production.rb`
- `config/storage.yml`

Recommended next check:
- Confirm whether production media is currently irreplaceable and whether R2 integration is planned or partially deployed elsewhere.

#### 2. Two deployment paths can drift

Why it matters:
- Kamal config and `bin/deploy` can diverge on env vars, image names, restart behavior, or secrets.
- Operational debugging becomes ambiguous because observed production behavior might come from either path.

Evidence:
- `config/deploy.yml`
- `bin/deploy`

Recommended next check:
- Keep `bin/deploy` documented as canonical until Kamal is actually adopted
- If Kamal becomes active later, update `docs/current_deploy_runbook.md` immediately

#### 3. Single-node failure takes down app, jobs, cable, and DB together

Why it matters:
- The current stack is intentionally simple, but the same host stores the database, serves traffic, runs jobs, and handles realtime updates.
- A host-level issue becomes a full-service outage.

Evidence:
- `config/database.yml`
- `config/deploy.yml`
- `docs/oracle_server_info.md`

Recommended next check:
- Validate backup restore procedure and estimate recovery time from a dead host scenario.

### Medium

#### 4. Litestream backup is conditional, not guaranteed by image alone

Why it matters:
- The image contains Litestream, but replication only starts when replica env vars are present.
- It is easy to think backup is “on” because the binary and config exist.

Evidence:
- `Dockerfile`
- `bin/docker-entrypoint`
- `config/litestream.yml`

Recommended next check:
- Verify production container env actually contains all `LITESTREAM_*` values and that replica objects are being written to R2.

#### 5. Public IP volatility creates DNS fragility

Why it matters:
- The Oracle doc says the IP is not reserved.
- A restart or recreation may require manual DNS updates.

Evidence:
- `docs/oracle_server_info.md`
- `docs/manual_setup_guide.md`

Recommended next check:
- Reserve the IP or document a fast update path and health-check verification process.

#### 6. 1GB RAM leaves little operating margin

Why it matters:
- Rails, SQLite, Docker, and background work all share a tiny host.
- Swap reduces crashes but can degrade latency or lead to unstable behavior under spikes.

Evidence:
- `docs/oracle_server_info.md`
- `config/deploy.yml`

Recommended next check:
- Record actual memory usage under representative load and define the threshold for moving to a larger instance.

### Low

#### 7. Architecture docs have drifted from actual infrastructure

Why it matters:
- New contributors may make wrong assumptions about provider, storage, or deployment.
- This is mainly a coordination problem, but it compounds incident response mistakes.

Evidence:
- `docs/prod_req.md`
- `docs/oracle_server_info.md`

Recommended next check:
- Refresh PRD deployment notes or add a “current reality” appendix.

## Recovery and Operations Questions Still Open

- Has Litestream restore been tested end to end against the current R2 bucket?
- Is there a documented procedure for rebuilding a host and reattaching restored SQLite files?
- Which deployment path is currently used in practice: Kamal or `bin/deploy`?
- Are production secrets stored in `.kamal/secrets`, CI/CD variables, shell history, or somewhere else?
- Is media backup handled independently from DB backup today?

## Recommended Immediate Follow-Ups

1. Keep the canonical production deploy path documented in `docs/current_deploy_runbook.md`.
2. Verify whether production Active Storage should remain local or move to R2.
3. Confirm Litestream replication is active in production and test restore.
4. Record current server capacity headroom on the 1GB Oracle VM.
5. Update architecture docs so they reflect Oracle vs Hetzner reality and current storage behavior.
