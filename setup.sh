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

# Funzione per chiedere la chiave API di Tailscale
ask_tailscale_api_key() {
  read -s -p "Enter your Tailscale API key: " tailscale_api_key
  echo
}

# Aggiornamento dei pacchetti e installazione di Docker
echo "Updating package lists and installing Docker and Docker Compose..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y docker-compose-plugin

# Determina se usare "docker-compose" o "docker compose"
if command -v docker-compose &> /dev/null; then
  DOCKER_COMPOSE_CMD="docker-compose"
else
  DOCKER_COMPOSE_CMD="docker compose"
fi

# Verifica se il file .env esiste
if [ -f .env ]; then
  while true; do
    read -p ".env file already exists. Do you want to keep it? (y/n): " yn
    case $yn in
        [Yy]* ) 
          source .env
          echo "Using existing .env file."
          use_existing_env=true
          break;;
        [Nn]* ) 
          echo "Removing existing .env file..."
          rm .env
          use_existing_env=false
          break;;
        * ) echo "Please answer yes or no.";;
    esac
  done
else
  use_existing_env=false
fi

# Se non si utilizza il file .env esistente, chiedere password e chiave API
if [ "$use_existing_env" = false ]; then
  ask_password
  ask_tailscale_api_key

  # Crea un file .env e aggiungi le variabili d'ambiente
  echo "Creating .env file..."
  cat <<EOL > .env
SA_PASSWORD=$password1
TAILSCALE_API_KEY=$tailscale_api_key
EOL
  echo ".env file created with user-defined values."
fi

# Verifica se Docker è installato
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker first."
  exit 1
fi

# Verifica se Docker Compose è installato
if ! command -v ${DOCKER_COMPOSE_CMD} &> /dev/null; then
  echo "Docker Compose is not installed. Please install Docker Compose first."
  exit 1
fi

# Costruisci le immagini Docker usando Docker Compose
echo "Building Docker images with Docker Compose..."
${DOCKER_COMPOSE_CMD} build

# Avvia Docker Compose
echo "Starting Docker Compose..."
${DOCKER_COMPOSE_CMD} up -d

echo "Setup and launch complete. Containers are running."
