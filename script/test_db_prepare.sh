#!/bin/bash
# workaround until upgrade to Rails 4
rake db:structure:dump; rake db:structure:add_postgis_extension; echo 'DROP DATABASE aluvi_test; CREATE DATABASE aluvi_test;' |  psql aluvi; psql aluvi_test < db/development_structure.sql 
