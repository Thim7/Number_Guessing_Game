#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\nEnter your username:"
read USERNAME
USERNAME_DB=$($PSQL "select username from users where username='$USERNAME'")
if [[ -z $USERNAME_DB ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "insert into users(username) values('$USERNAME')")
else
  USER_GAMES=$($PSQL "select count(*) as games_played, min(best_guess) from users inner join games using(user_id) where username='$USERNAME_DB'")
  echo $USER_GAMES | while IFS=\| read GAMES_PLAYED BEST_GUESS
  do
  echo -e "\nWelcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  done
fi

SECRET_NUMBER=$(( 1 + $RANDOM % 1000 ))
echo -e "\nGuess the secret number between 1 and 1000:"
GUESS=1
while read GUESS_NUMBER
do
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    if [[ $GUESS_NUMBER -eq $SECRET_NUMBER ]] 
    then
      break;
    else
      if [[ $GUESS_NUMBER -gt  $SECRET_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      else
        echo -e "\nIt's higher than that, guess again:"
      fi
    fi
  fi

  GUESS=$(( $GUESS + 1 ))
done
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
INSERT_NEW_GAME=$($PSQL "insert into games(best_guess, user_id) values($GUESS, $USER_ID)")
echo -e "\nYou guessed it in $GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"


