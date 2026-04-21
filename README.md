# s3-sync

A small container that periodically moves files from a local directory to S3 (or any rclone-supported object store) on a cron schedule. Designed for edge devices: each run verifies the upload (checksum) before deleting the local copy, retries on network failures, and resumes on the next tick if anything is still outstanding.

Under the hood it's [rclone](https://rclone.org) driven by [supercronic](https://github.com/aptible/supercronic).

## Usage

```sh
docker run -d \
  -v /var/data:/app/source \
  -e DEST_DIR=dest:my-bucket/path \
  -e RCLONE_CONFIG_DEST_TYPE=s3 \
  -e RCLONE_CONFIG_DEST_PROVIDER=AWS \
  -e RCLONE_CONFIG_DEST_ENV_AUTH=true \
  -e RCLONE_CONFIG_DEST_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID=... \
  -e AWS_SECRET_ACCESS_KEY=... \
  ghcr.io/<owner>/s3-sync:latest
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `SOURCE_DIR` | `/app/source` | Local directory to move files from. Mount your data here. |
| `DEST_DIR` | _(required)_ | rclone destination in `remote:bucket/path` form. |
| `CRON_SCHEDULE` | `*/2 * * * *` | Cron expression (supercronic format). |
| `SYNC_CMD` | `move` | rclone subcommand. `move` uploads then deletes; `copy` leaves the source intact; `sync` mirrors. |
| `SYNC_OPTIONS` | `--checksum --delete-empty-src-dirs --retries 10 --low-level-retries 20` | Flags passed to rclone. `--checksum` forces hash verification before delete. |

### Configuring the rclone remote

The destination is a named rclone remote configured entirely through environment variables — no config file required. Pick any name (e.g. `dest`, `s3`, `backup`) and export one env var per remote option as `RCLONE_CONFIG_<NAME>_<OPTION>`.

For AWS S3 with standard AWS credentials:

```sh
RCLONE_CONFIG_DEST_TYPE=s3
RCLONE_CONFIG_DEST_PROVIDER=AWS
RCLONE_CONFIG_DEST_ENV_AUTH=true          # use AWS_* env vars for credentials
RCLONE_CONFIG_DEST_REGION=us-east-1
DEST_DIR=dest:my-bucket/path
```

With `ENV_AUTH=true`, rclone picks up `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, and IAM instance/container roles automatically.

The same pattern works for any rclone backend — see the [rclone S3 options](https://rclone.org/s3/) or [full backend list](https://rclone.org/overview/). For example, Cloudflare R2:

```sh
RCLONE_CONFIG_DEST_TYPE=s3
RCLONE_CONFIG_DEST_PROVIDER=Cloudflare
RCLONE_CONFIG_DEST_ACCESS_KEY_ID=...
RCLONE_CONFIG_DEST_SECRET_ACCESS_KEY=...
RCLONE_CONFIG_DEST_ENDPOINT=https://<account>.r2.cloudflarestorage.com
```

### Upload verification

`rclone move` (the default `SYNC_CMD`) transfers each file, compares checksums against the destination, and only then deletes the local copy. If any step fails — network drop, partial upload, checksum mismatch — the local file is left in place and the next cron tick retries it. Empty directories are pruned on success via `--delete-empty-src-dirs`.
