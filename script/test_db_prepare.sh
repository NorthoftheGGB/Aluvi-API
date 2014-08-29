#!/bin/bash
# workaround until upgrade to Rails 4
rake db:structure:dump; rake db:structure:add_postgis_extension; echo 'DROP DATABASE voco_test; CREATE DATABASE voco_test;' |  psql voco; psql voco_test < db/development_structure.sql 
