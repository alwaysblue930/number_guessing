#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

CURRENT_USER=""

USER_MENU(){
  if [[ -n $1 ]]; then
    echo "$1"
  fi
  echo -e "\nEnter your username:"
  read INPUT
  CURRENT_USER=$INPUT
  if [[ ${#INPUT} -le 22 ]]; then
    USER_EXISTS=$($PSQL "SELECT * FROM users WHERE username='$INPUT';")
    if [[ -z $USER_EXISTS ]]; then
        INSERT_RESULT=$($PSQL "INSERT INTO users VALUES('$INPUT');")
        if [[ $? -ne 0 ]]; then
          USER_MENU "Failed to create a user with username $INPUT"
        else
          echo "Welcome, $INPUT! It looks like this is your first time here."
          USERNAME="$INPUT"
        fi
    else
      USER_INFO=$($PSQL "SELECT username, COUNT(*), MIN(guesses) FROM users INNER JOIN games USING(username) WHERE username='$INPUT' GROUP BY username;")
      echo "$USER_INFO" | while IFS='|' read -r USERNAME GAMES_PLAYED BEST_SCORE
        do
          echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses"
        done
    fi
  else
      USER_MENU "Please enter a valid username."
  fi
}

GOAL=$(( RANDOM % 1000 + 1))
TRIES=1

GUESS_MENU(){
  if [[ -n $1 ]]; then
    echo "$1"
  fi

  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    GUESS_MENU "That is not an integer, guess again:"
  else
    ((TRIES++))
    if (( GUESS == GOAL)); then
      echo "You guessed it in $TRIES tries. The secret number was $GOAL. Nice job!"
      GAME_RECORDED=$($PSQL "INSERT INTO games(username, guesses) VALUES('$CURRENT_USER', $TRIES);")
    elif (( GUESS < GOAL )); then
      GUESS_MENU "It's higher than that, guess again:"
    else
      GUESS_MENU "It's lower than that, guess again:"
    fi
  fi
}

USER_MENU
GUESS_MENU