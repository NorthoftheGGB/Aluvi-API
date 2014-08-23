#!/bin/bash
ssh-add keys/voco_heroku_id_rsa
echo 'type Scheduler.build_commuter_trips to run the commuter trip scheduler' 
heroku run --app voco-test rails console
