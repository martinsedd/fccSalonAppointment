#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

display_services() {
  echo "Welcome to the Salon! Here are our services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

prompt_for_service_id() {
  echo -e "\nPlease select a service by entering the corresponding number:"
  read SERVICE_ID_SELECTED
  SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
}

display_services

SERVICE_ID_SELECTED=0

# Prompt for a valid service ID until a valid one is entered
while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $SERVICE_EXISTS ]]; do
  prompt_for_service_id
  if [[ -z $SERVICE_EXISTS ]]; then
    echo -e "\nInvalid service. Please select a valid service."
    display_services
  fi
done

echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nIt looks like you are a new customer. Please enter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
echo -e "\nPlease enter the time for your appointment:"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
