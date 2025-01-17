#!/bin/bash

# Controlla se lo script è eseguito come root, altrimenti fallisce con un messaggio.
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root or use sudo to execute this script."
  exit 1
fi

# Funzione per chiedere e confermare la password
ask_password() {
  while true; do
    read -s -p "Enter a new SA_PASSWORD: " password1
    echo
    read -s -p "Confirm SA_PASSWORD: " password2
    echo
    if [ "$password1" == "$password2" ]; then
      echo "Passwords match."
      break
    else
      echo "Passwords do not match. Please try again."
    fi
  done
}

# Aggiornamento dei pacchetti e installazione di Docker
echo "Updating package lists and installing Docker and Docker Compose..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y docker-compose-plugin

# Chiede e conferma la password
ask_password

# Verifica se il file .env esiste
if [ -f .env ]; then
  echo ".env file already exists. Please make sure it contains the correct configurations."
else
  # Crea un file .env e aggiungi le variabili d'ambiente
  echo "Creating .env file..."
  cat <<EOL > .env
SA_PASSWORD=$password1
EOL
  echo ".env file created with user-defined values."
fi

# Verifica se Docker è installato
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker first."
  exit 1
fi

# Verifica se Docker Compose è installato
if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose is not installed. Please install Docker Compose first."
  exit 1
fi

# Avvia Docker Compose
echo "Starting Docker Compose..."
docker-compose up -d

echo "Setup and launch complete. Containers are running."
