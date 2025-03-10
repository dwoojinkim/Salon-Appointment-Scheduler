#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n\n~~~~~ My Salon ~~~~~\n\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo "Welcome to my salon. How can I help you?"
  fi


  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
      MAIN_MENU "That is not a valid service number. Please select a choice below:"
  else
    ON_SERVICE_SELECT $SERVICE_ID_SELECTED
  fi
  
}

ON_SERVICE_SELECT() {
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $1")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")

  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "That service is not available. How can I help you?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nLooks like you're new! What's your name?"
      read CUSTOMER_NAME

      ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU