#!/bin/sh

PATH=/opt/rbenv/bin/:$PATH
eval "$(rbenv init -)"

cd /var/www/shibcert-prototype
bundle exec rails runner lib/mail_processor.rb
