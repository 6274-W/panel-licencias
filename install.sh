#!/bin/bash
# --- CONFIGURACIÓN ---
# Aquí debes poner la URL de un archivo de texto en tu GitHub o servidor 
# que contenga las llaves permitidas.
URL_KEYS="https://raw.githubusercontent.com/TU_USUARIO/redapn/main/keys.txt"
URL_PANEL="https://raw.githubusercontent.com/TU_USUARIO/redapn/main/redapn.sh"

clear
echo -e "\e[1;36m       RED APN PRO - INSTALADOR ELITE\e[0m"
echo -ne "\e[1;33mINGRESE SU LLAVE DE ACCESO: \e[0m"
read user_key

# Verificación de la Key
if curl -s "$URL_KEYS" | grep -qW "$user_key"; then
    echo -e "\e[1;32m✔ Key Validada Correctamente.\e[0m"
    
    # --- PROCESO DE INSTALACIÓN ---
    apt update && apt install -y curl at
    mkdir -p /etc/redapn
    curl -o /usr/local/bin/panel "$URL_PANEL"
    chmod +x /usr/local/bin/panel
    
    # Crear alias para que el cliente solo escriba 'panel'
    echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    
    # --- LÓGICA DE UN SOLO USO ---
    # Aquí es donde ocurre la magia: Debes usar un script en tu servidor
    # o una API para borrar la key de la lista después de usarse.
    # Por ahora, simulamos la instalación exitosa.
    
    echo -e "\e[1;32m✔ Instalación Completa. Escriba 'panel' para iniciar.\e[0m"
else
    echo -e "\e[1;31m✘ Key Inválida o Ya Utilizada.\e[0m"
    exit 1
fi
