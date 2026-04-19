#!/bin/bash
clear
# Ocultar rastro
rm -rf $0 &> /dev/null

echo -e "\e[1;32m[+] Iniciando Instalador Elite...\e[0m"

# 1. Instalar dependencias para ejecutar binarios
sudo apt-get update -y &> /dev/null
sudo apt-get install -y libstdc++6 libcurl4 wget curl &> /dev/null

# 2. Pedir la Key
echo -ne "\e[1;33m🔑 INGRESE SU LLAVE DE ACTIVACIÓN: \e[0m"
read KEY
HWID=$(cat /etc/machine-id 2>/dev/null | cut -c1-10)

# 3. Validar con tu servidor
SVR="prueba.red-pro.site" # <---
CHECK=$(curl -s "http://$SVR/licencias/validar.php?key=$KEY&hwid=$HWID")

if  "$CHECK" == "OK" ; then
    echo -e "\e[1;32m[+] Licencia Válida.\e[0m"
    
    # Descargar el binario que compilamos antes
    wget -q --no-cache -O /usr/local/bin/panel "https://raw.githubusercontent.com/6274-W/panel-licencias/main/core_engine"
    chmod +x /usr/local/bin/panel
    
    # Crear el comando 'panel'
    echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    
    echo -e "\e[1;32m[+] TODO LISTO. Escriba 'panel'\e[0m"
else
    echo -e "\e[1;31m[!] Error: $CHECK\e[0m"
    exit 1
fi
