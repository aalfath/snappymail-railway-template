# SnappyMail webmail for Railway.
# Official image, pinned by version and digest. Bump both together (see CHANGELOG.md).
FROM djmaze/snappymail:v3.0.1.2@sha256:e2fa8e4f348905831f95826bf6c0711e15f85aec2bab3e96ffca0dd45b2e8aed

COPY railway-start.sh /railway-start.sh
COPY set-admin-password.php /railway/set-admin-password.php
RUN chmod 755 /railway-start.sh && chmod 644 /railway/set-admin-password.php

# nginx serves the app on $PORT (8888 by default); data lives on a Railway volume at /var/lib/snappymail.
EXPOSE 8888
CMD ["/railway-start.sh"]
