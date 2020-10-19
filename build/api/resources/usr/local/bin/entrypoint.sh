#! /bin/sh

set -e

bundle exec rake db:migrate

bundle exec rackup --host 0.0.0.0 -p 80
