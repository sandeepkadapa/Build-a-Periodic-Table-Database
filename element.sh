#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

GET_RESULTS() {
  if [[ $1 ]]
  then
    IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME <<< "$1"
    GET_PROPERTIES_RESULT=$($PSQL "SELECT * FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
    IFS="|" read -r ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE_ID <<< "$GET_PROPERTIES_RESULT"
    GET_TYPES_RESULT=$($PSQL "SELECT * FROM types WHERE type_id=$TYPE_ID")
    IFS="|" read -r TYPE_ID TYPE <<< "$GET_TYPES_RESULT"
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  else
    echo "I could not find that element in the database."
  fi
}

MAIN_FUNC() {
  ARG=$1
  if [[ -z $ARG ]]
  then
    echo -e "Please provide an element as an argument."
  else
    if [[ $ARG =~ ^[0-9]+$ ]]
    then
      GET_ELEMENTS_RESULT=$($PSQL "SELECT * FROM elements WHERE atomic_number=$ARG")
      GET_RESULTS $GET_ELEMENTS_RESULT
    elif [[ $ARG =~ ^[a-zA-Z]+$ && ${#ARG} -le 2 ]]
    then
      GET_ELEMENTS_RESULT=$($PSQL "SELECT * FROM elements WHERE symbol = '$ARG'")
      GET_RESULTS $GET_ELEMENTS_RESULT
    elif [[ $ARG =~ ^[a-zA-Z]+$ && ${#ARG} -gt 2 ]]
    then
      GET_ELEMENTS_RESULT=$($PSQL "SELECT * FROM elements WHERE name = '$ARG'")
      GET_RESULTS $GET_ELEMENTS_RESULT
    else
      echo "I could not find that element in the database."
    fi
  fi
}

MAIN_FUNC $1
