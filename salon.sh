#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
      else
      echo -e "\nWelcome to My Salon, how can I help you?\n"
    fi

  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do 
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

  read SERVICE_ID_SELECTED
  SERVICE_QUERY=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_QUERY ]]
    then MAIN_MENU "I could not find that service. What would you like today?"
    else
      BOOK_APPOINTMENT $SERVICE_ID_SELECTED
  fi
}

BOOK_APPOINTMENT() {
  SERVICE_REQUESTED=$($PSQL "SELECT name FROM services WHERE service_id = $1") 

  echo "What's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your$SERVICE_REQUESTED, $CUSTOMER_NAME?"
  read SERVICE_TIME

  if [[ -z SERVICE_TIME ]]
    then 
      echo -e "Please choose a time for your appointment."
    else
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, '$1', '$SERVICE_TIME')")

      echo -e "\nI have put you down for a$SERVICE_REQUESTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU