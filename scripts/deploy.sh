#!/bin/bash
git stash
git pull
git stash apply
bundle install
bin/rake db:migrate
