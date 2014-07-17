git push alpha master
heroku run --app voco-alpha rake db:migrate
heroku restart --app voco-alpha
