# Changelog

## 3.0.1.2 (2026-11-16)

- First release of the Railway template.
- SnappyMail 3.0.1, image `djmaze/snappymail:v3.0.1.2@sha256:e2fa8e4f348905831f95826bf6c0711e15f85aec2bab3e96ffca0dd45b2e8aed`.
- Admin panel password comes from `SNAPPYMAIL_ADMIN_PASSWORD` (a generated secret); no `admin_password.txt` is written.
- Data on a volume at `/var/lib/snappymail`.
