#!/bin/bash

# Función para detectar el sistema operativo e instalar Azure CLI
install_azure_cli() {
  OS=$(uname -s)

  case "$OS" in
    Linux)
      DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

      if [[ "$DISTRO" == *"Ubuntu"* || "$DISTRO" == *"Debian"* ]]; then
        echo "Instalando Azure CLI en Ubuntu/Debian..."
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list'
        sudo apt-get update
        sudo apt-get install -y azure-cli
      elif [[ "$DISTRO" == *"CentOS"* || "$DISTRO" == *"RHEL"* ]]; then
        echo "Instalando Azure CLI en CentOS/RHEL..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
        sudo yum install -y azure-cli
      elif [[ "$DISTRO" == *"Fedora"* ]]; then
        echo "Instalando Azure CLI en Fedora..."
        sudo dnf install -y azure-cli
      fi
      ;;
    
    Darwin)
      echo "Instalando Azure CLI en macOS..."
      brew update && brew install azure-cli
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      echo "Instalando Azure CLI en Windows..."
      powershell -Command "Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -ArgumentList '/I .\AzureCLI.msi /quiet /norestart' -NoNewWindow -Wait"
      ;;

    *)
      echo "Sistema operativo no reconocido o no soportado"
      exit 1
      ;;
  esac
}

# Función para configurar la CLI de Azure
configure_azure_cli() {
  echo "Iniciando sesión en Azure..."
  az login --use-device-code
}

# Función para crear la aplicación de servicio
create_service_principal() {
  # Configuración de la aplicación de servicio
  APP_NAME="nombre-de-tu-aplicacion"   # Cambia esto por el nombre de tu aplicación
  ROLE="Contributor"                  # El rol que asignarás a la aplicación (Contributor, Owner, etc.)
  SUBSCRIPTION_ID=$(az account show --query id -o tsv)  # Obtiene el ID de la suscripción actual

  # 1. Crea una aplicación de servicio (Service Principal)
  echo "Creando la aplicación de servicio con nombre: $APP_NAME"
  SP_INFO=$(az ad sp create-for-rbac --name "$APP_NAME" --role $ROLE --scopes /subscriptions/$SUBSCRIPTION_ID --sdk-auth)

  # 2. Extrae valores de las credenciales creadas
  echo "Extrayendo las credenciales..."
  ARM_CLIENT_ID=$(echo $SP_INFO | jq -r .clientId)
  ARM_CLIENT_SECRET=$(echo $SP_INFO | jq -r .clientSecret)
  ARM_TENANT_ID=$(echo $SP_INFO | jq -r .tenantId)
  ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID

  # 3. Muestra los valores extraídos
  echo "Client ID: $ARM_CLIENT_ID"
  echo "Client Secret: $ARM_CLIENT_SECRET"
  echo "Tenant ID: $ARM_TENANT_ID"
  echo "Subscription ID: $ARM_SUBSCRIPTION_ID"

  # 4. Exporta las credenciales a variables de entorno
  echo "Exportando credenciales a variables de entorno..."
  export ARM_CLIENT_ID=$ARM_CLIENT_ID
  export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
  export ARM_TENANT_ID=$ARM_TENANT_ID
  export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID

  # Opcional: Guarda las variables en un archivo .env para futuras sesiones
  echo "Guardando credenciales en .env..."
  cat <<EOT >> .env
export ARM_CLIENT_ID=$ARM_CLIENT_ID
export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
export ARM_TENANT_ID=$ARM_TENANT_ID
export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
EOT

  echo "Proceso completo. Las credenciales están listas para ser utilizadas."
}

# Detectar el sistema operativo e instalar Azure CLI
install_azure_cli

# Configurar Azure CLI y autenticarse
configure_azure_cli

# Crear la aplicación de servicio y obtener las credenciales
create_service_principal
