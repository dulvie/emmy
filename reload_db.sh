#!/bin/bash -x
db_name=$1

if [ "$db_name" == "" ]; then
  db_name='emmy_development'
fi
be='bundle exec'
dropdb $db_name && $be rake db:create && $be rake db:migrate && $be rake db:seed && rm public/system/documents
