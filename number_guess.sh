#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read INPUT

USERNAME=$INPUT
USER_EXISTS=$($PSQL "SELECT * FROM users WHERE username='$INPUT';")
if [[ -z $USER_EXISTS ]]; then
  INSERT_RESULT=$($PSQL "INSERT INTO users VALUES('$INPUT');")
  echo "Welcome, $INPUT! It looks like this is your first time here."
  USERNAME=$INPUT
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games LEFT JOIN users USING(username) WHERE username='$INPUT';")
  BEST_SCORE=$($PSQL "SELECT MIN(guesses) FROM games LEFT JOIN users USING(username) WHERE username='$INPUT';")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
fi

GOAL=$(( RANDOM % 1000 + 1 ))
TRIES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

until [[ $GUESS == $GOAL ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
    ((TRIES++))
  else
    if [[ $GUESS < $GOAL ]]; then
      echo "It's higher than that, guess again:"
      read GUESS
      ((TRIES++))
    else
      echo "It's lower than that, guess again:"
      read GUESS
      ((TRIES++))
    fi
  fi
done

((TRIES++))

GAME_RECORDED=$($PSQL "INSERT INTO games(username, guesses) VALUES('$USERNAME', $TRIES);")
    
echo "You guessed it in $TRIES tries. The secret number was $GOAL. Nice job!"