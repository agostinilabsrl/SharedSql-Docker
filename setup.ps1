# Controlla i permessi di amministratore
if ((-not [System.Environment]::UserInteractive) -or -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Please run this script as Administrator."
    exit 1
}

# Funzione per chiedere e confermare la password
function Ask-Password {
    do {
        $password1 = Read-Host "Enter a new SA_PASSWORD" -AsSecureString
        $password2 = Read-Host "Confirm SA_PASSWORD" -AsSecureString
        if ($password1 -eq $password2) {
            Write-Host "Passwords match."
            break
        } else {
            Write-Host "Passwords do not match. Please try again."
        }
    } until ($password1 -eq $password2)
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1))
}

# Installazione di Docker Desktop
Write-Host "Please ensure Docker Desktop is installed manually as it needs manual interaction to set up."

# Chiedi e conferma la password
$saPassword = Ask-Password

# Creare il file .env
if (Test-Path -Path .\.env) {
    Write-Host ".env file already exists. Please make sure it contains the correct configurations."
} else {
    $saPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1))
    Set-Content .\.env "SA_PASSWORD=$saPasswordPlain"
    Write-Host ".env file created with user-defined values."
}

# Builda i container
Write-Host "Building Docker Compose solution..."
docker-compose build

# Avvia Docker Compose
Write-Host "Starting Docker Compose..."
docker-compose up -d

Write-Host "Setup and launch complete. Containers are running."
