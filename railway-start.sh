#!/bin/sh
# Railway wrapper around the official SnappyMail entrypoint.
# 1. listens on $PORT (default 8888),
# 2. creates SnappyMail's config on the volume on first boot,
# 3. sets the admin panel password from SNAPPYMAIL_ADMIN_PASSWORD,
# 4. hands over to the upstream /entrypoint.sh (nginx + php-fpm under supervisord).
set -eu

PORT="${PORT:-8888}"
DATA=/var/lib/snappymail
CONFIG="$DATA/_data_/_default_/configs/application.ini"

if [ "$PORT" != "8888" ]; then
    echo "[railway] nginx will listen on port $PORT"
    sed -i "s/listen 8888;/listen $PORT;/; s/listen \[::\]:8888;/listen [::]:$PORT;/" /etc/nginx/nginx.conf
    sed -i "s/127.0.0.1 8888/127.0.0.1 $PORT/; s#127.0.0.1:8888#127.0.0.1:$PORT#g" /entrypoint.sh
fi

# The upstream image disables the stock php-fpm pools by renaming them in a layer.
# On Railway those files can reappear and the stock "www" pool then takes port 9000
# ("unable to set listen address as it's already used in another pool 'www'").
for f in www.conf docker.conf zz-docker.conf; do
    if [ -f "/usr/local/etc/php-fpm.d/$f" ]; then
        echo "[railway] removing stock php-fpm pool file $f"
        rm -f "/usr/local/etc/php-fpm.d/$f"
    fi
done

# Railway volumes mount owned by root.
mkdir -p "$DATA"
chown -R www-data:www-data "$DATA"

if [ ! -f "$CONFIG" ]; then
    echo "[railway] first boot: creating SnappyMail data and config in $DATA"
    su - www-data -s /bin/sh -c 'php /snappymail/index.php' > /tmp/first-run.out 2>&1 || { cat /tmp/first-run.out; exit 1; }
fi

if [ -n "${SNAPPYMAIL_ADMIN_PASSWORD:-}" ]; then
    php /railway/set-admin-password.php "$CONFIG"
    chown www-data:www-data "$CONFIG"
else
    echo "[railway] WARNING: SNAPPYMAIL_ADMIN_PASSWORD is empty. SnappyMail will write a random admin password to $DATA/_data_/_default_/admin_password.txt"
fi

exec /entrypoint.sh
