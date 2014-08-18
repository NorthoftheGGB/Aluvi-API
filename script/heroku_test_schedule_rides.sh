#!/bin/bash
ssh-add keys/voco_heroku_id_rsa
echo 'Scheduler.build_commuter_trips' | heroku run --app voco-test rails console
