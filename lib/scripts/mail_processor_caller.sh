#!/bin/sh

eval "$(rbenv init -)"

cd ~/shibcert/
bundle exec rails runner lib/mail_processor.rb
