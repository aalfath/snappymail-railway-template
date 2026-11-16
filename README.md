[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/snappymail?utm_medium=integration&utm_source=button&utm_campaign=snappymail)

# SnappyMail on Railway

One-click Railway template for [SnappyMail](https://snappymail.eu), a fast, open-source webmail client for your existing IMAP/SMTP mail server.

## What it deploys

- **SnappyMail 3.0.1**, built from the official image `djmaze/snappymail:v3.0.1.2`, pinned by digest in the [`Dockerfile`](Dockerfile).
- nginx + PHP-FPM in one service, listening on `PORT` (8888), with a public Railway domain.
- A Railway volume at `/var/lib/snappymail` for the configuration, domains, contacts, user settings and cache.
- No database: SnappyMail stores everything in files (SQLite for contacts).

## Variables

| Variable | Default | What it does |
|---|---|---|
| `SNAPPYMAIL_ADMIN_PASSWORD` | generated secret | Password for the admin panel at `/?admin` (login `admin`). Set again on every start, so the Railway variable stays the source of truth. |
| `PORT` | `8888` | Port nginx listens on. |

## After deploying

1. Open `https://YOUR-DOMAIN/?admin` and sign in as `admin` with the `SNAPPYMAIL_ADMIN_PASSWORD` value from the service's Variables tab.
2. Under **Domains**, add your mail domain with its IMAP and SMTP servers (or edit the preset Gmail/Outlook/Yahoo entries).
3. Users then sign in on `https://YOUR-DOMAIN/` with their own mail address and password. SnappyMail does not store mail: it reads it from your IMAP server.

To change the admin password, change `SNAPPYMAIL_ADMIN_PASSWORD` and redeploy. A password changed in the admin panel is replaced by the variable on the next restart.

## How the wrapper works

`railway-start.sh` runs before the upstream entrypoint. It makes nginx listen on `PORT`, creates SnappyMail's data folder on the volume on first boot, and writes a hash of `SNAPPYMAIL_ADMIN_PASSWORD` into `application.ini` (`set-admin-password.php`), so no random admin password ends up in a file. Then it hands over to the official `/entrypoint.sh`.

## Updates

Each new SnappyMail release is a change to the `FROM` line on this repo's `main` branch, with an entry in [`CHANGELOG.md`](CHANGELOG.md). Railway shows deployers of this template an "update available" notice when `main` changes, and they choose when to apply it. Read the changelog first: breaking changes are listed at the top of each entry.

## License

SnappyMail is AGPL-3.0, by [the-djmaze/snappymail](https://github.com/the-djmaze/snappymail). This repo only holds the Railway wrapper.
