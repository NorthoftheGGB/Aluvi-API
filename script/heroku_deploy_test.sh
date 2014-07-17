git push test master
heroku run --app voco-test rake db:migrate
heroku restart --app voco-test
