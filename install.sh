#!/bin/bash
clear
rm -rf /usr/local/bin/panel &> /dev/null

echo -e "\e[1;32m[+] Iniciando Instalador Elite...\e[0m"

# Dependencias
sudo apt-get update -y &> /dev/null
sudo apt-get install -y libstdc++6 libcurl4 wget curl &> /dev/null

echo -ne "\e[1;33m🔑 LLAVE DE ACTIVACIÓN: \e[0m"
read KEY
HWID=$(cat /etc/machine-id 2>/dev/null | cut -c1-10)

SVR="prueba.red-pro.site"
CHECK=$(curl -s "http://$SVR/licencias/validar.php?key=$KEY&hwid=$HWID")

if [[ "$CHECK" == "OK" ]]; then
    echo -e "\e[1;32m[+] Licencia Válida.\e[0m"
    
    # DESCARGA DIRECTA DEL BINARIO (Sin Base64)
    wget -q --no-cache -O /usr/local/bin/panel "http://$SVR/core_engine"
    
    chmod +x /usr/local/bin/panel
    
    # Crear el alias
    if ! grep -q "alias panel" ~/.bashrc; then
        echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    fi
    
    echo -e "\e[1;32m[+] INSTALACIÓN COMPLETADA.\e[0m"
    echo -e "\e[1;37mCierre y abra su terminal o escriba: \e[1;33mpanel\e[0m"
else
    echo -e "\e[1;31m[!] Error: $CHECK\e[0m"
    exit 1
fi
