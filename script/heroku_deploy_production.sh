ssh-add keys/voco_heroku_id_rsa
git push test master
heroku run --app aluvi rake db:migrate
heroku restart --app aluvi
