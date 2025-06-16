#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # query services
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
    do
      echo "$SERVICE_ID) $SERVICE"
    done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # query service_id con salon_selection
    QUERY_SALON=$($PSQL "SELECT * FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $QUERY_SALON ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      # query si esta en db
      QUERY_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # si no esta creamos uno y pedimos su nombre
      if [[ -z $QUERY_CUSTOMER_NAME ]]
      then
        # si la esta le enviamos el mensaje formateado
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        QUERY_CREAR_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        
        echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
        read SERVICE_TIME
        # query insertar hora
        QUERY_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        QUERY_CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$QUERY_CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
        # mensaje con fromateado
        echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        echo -e "\nWhat time would you like your cut, $QUERY_CUSTOMER_NAME?"
        read SERVICE_TIME
        # query insertar hora
        QUERY_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        QUERY_CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$QUERY_CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
        echo -e "\nI have put you down for a cut at $SERVICE_TIME, $QUERY_CUSTOMER_NAME."
      fi
    fi
  fi
}

MAIN_MENU