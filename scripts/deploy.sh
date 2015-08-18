#!/bin/bash
git pull
bundle install
bin/rake db:migrate
