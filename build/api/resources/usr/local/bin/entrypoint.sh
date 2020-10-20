#! /bin/sh

set -e

bundle exec rake db:migrate

ruby app.rb
