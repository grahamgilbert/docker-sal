#!/bin/bash

cd $APP_DIR
ADMIN_PASS=${ADMIN_PASS:-}
python manage.py syncdb --noinput
python manage.py migrate --noinput
python manage.py collectstatic --noinput

if [ ! -z "$ADMIN_PASS" ] ; then
  python manage.py update_admin_user --username=admin --password=$ADMIN_PASS
else
  python manage.py update_admin_user --username=admin --password=password
fi

chown -R app:app $APP_DIR
chmod go+x $APP_DIR

#service nginx restart