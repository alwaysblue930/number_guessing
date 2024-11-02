#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

echo "$USERNAME"
