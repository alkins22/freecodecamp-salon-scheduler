#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

APP_SCHEDULER() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]
  then
    echo "Sorry, we don't have any service right now"
  else
    echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi

  read SERVICE_ID_SELECTED

  CHOSEN_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $CHOSEN_SERVICE ]]
    then
      APP_SCHEDULER
    else
      echo -e "You chose" $CHOSEN_SERVICE
      echo -e "\nPlease provide your phone number."
      read CUSTOMER_PHONE

      CUSTOMER_NAME_MATCH_PHONE=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME_MATCH_PHONE ]]
          then
          echo -e "\nWe didn't find you in our system. Please provide you're name and we'll add you to our customer list."
          read CUSTOMER_NAME
          NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      echo -e "Great, thanks" $CUSTOMER_NAME
      echo -e "\nWhat time would you like to schedule your appointment?"
      read SERVICE_TIME

      if [[ -z $SERVICE_TIME ]]
        then
        echo -e "\nSorry, that didn't work. Please enter a time."
        else
        NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $(echo $CHOSEN_SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
      fi
  fi
}

APP_SCHEDULER



