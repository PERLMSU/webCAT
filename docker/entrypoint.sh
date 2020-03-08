#!/bin/sh

. /venv/bin/activate

if [ -z ${POSTGRES_HOST} && ! nc -z $POSTGRES_HOST $POSTGRES_PORT; ]
then
    echo "Waiting for postgres..."

    while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

python manage.py migrate

# Static files and media
python manage.py collectstatic --no-input --clear

exec "$@"