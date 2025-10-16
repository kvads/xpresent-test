#!/bin/bash

info() {
    { set +x; } 2> /dev/null
    echo '[INFO] ' "$@"
}
warning() {
    { set +x; } 2> /dev/null
    echo '[WARNING] ' "$@"
}
fatal() {
    { set +x; } 2> /dev/null
    echo '[ERROR] ' "$@" >&2
    exit 1
}

role=${CONTAINER_ROLE:-app}

if [ -z "$USER_NAME" ] || [ -z "$GROUP_NAME" ]; then
  fatal "USER_NAME or GROUP_NAME is not set."
fi

if [ ! -d "/var/www/html/vendor" ]; then
  echo "Installing Composer dependencies..."
  composer install --working-dir=/var/www/html --optimize-autoloader
  chown -R "$USER_NAME":"$GROUP_NAME" /var/www/html/vendor
fi


if [ "$role" = "app" ];
then

    exec /usr/local/sbin/php-fpm

elif [ "$role" = "scheduler" ];
then

    while [ true ]
    do
      php artisan schedule:run --verbose --no-interaction &
      sleep 60
    done

else

    echo "Could not match the container role \"$role\""
    exit 1

fi
