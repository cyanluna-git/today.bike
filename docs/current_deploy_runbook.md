# Current Deploy Runbook

> As of 2026-03-14, the canonical production deploy path for `today.bike` is the manual GHCR + SSH flow in `bin/deploy`.

## Canonical Path

Current production deploy path:

```text
Local working tree
  -> docker build (linux/amd64)
  -> push image to GHCR
  -> ssh to Oracle VM
  -> docker pull ghcr.io/cyanluna-git/today-bike:latest
  -> stop/remove today-bike container
  -> docker run today-bike with persistent volume
  -> HTTP health check on 217.142.238.243
```

Primary script:

- `bin/deploy`

Production target:

- server: `ubuntu@217.142.238.243`
- container: `today-bike`
- image: `ghcr.io/cyanluna-git/today-bike:latest`
- volume: `today-bike_storage:/rails/storage`

## Required Local Preconditions

Before deploy:

- `config/master.key` must exist locally
- Docker must be running locally
- SSH access to the Oracle VM must work
- `GHCR_TOKEN` must be set in the shell environment

Required token scope:

- `write:packages`

Recommended additional scope:

- `read:packages`
- `repo` if the package/repository setup requires it

Example:

```bash
export GHCR_TOKEN=ghp_xxx
bin/deploy
```

## Actual Script Behavior

`bin/deploy` currently does the following:

1. logs in to `ghcr.io`
2. builds a local Docker image for `linux/amd64`
3. tags and pushes `ghcr.io/cyanluna-git/today-bike:latest`
4. SSHes to the Oracle server and logs Docker into GHCR
5. pulls the latest image on the server
6. stops and removes the existing `today-bike` container
7. starts a new container with:
   - port mapping `80:80`
   - volume `today-bike_storage:/rails/storage`
   - `RAILS_MASTER_KEY`
   - `RAILS_SERVE_STATIC_FILES=true`
   - `SOLID_QUEUE_IN_PUMA=true`
8. checks `http://217.142.238.243/` for HTTP `200`

## Important Operational Notes

- This deploy path uses the current local working tree, not necessarily a pushed Git commit.
- If uncommitted local changes exist, they will be included in the deployed image.
- Production SQLite files and local Active Storage files live under `/rails/storage` on the Docker volume.
- `config/deploy.yml` still exists for Kamal, but it is not the currently used production path.

## Verification

Minimum post-deploy verification:

```bash
curl -I http://217.142.238.243/
```

Expected result:

- HTTP `200`

If health check fails:

```bash
ssh ubuntu@217.142.238.243 'docker logs today-bike --tail 50'
```

## Future Direction

Kamal configuration remains in the repository as a possible future deploy path, but until migration is explicitly completed, treat `bin/deploy` as the source of truth for production operations.
