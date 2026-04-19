#!/bin/bash
clear
# Ocultar rastro (borra el instalador al terminar)
rm -rf $0 &> /dev/null

echo -e "\e[1;32m[+] Iniciando Instalador Elite...\e[0m"

# 1. Instalar dependencias necesarias
sudo apt-get update -y &> /dev/null
sudo apt-get install -y libstdc++6 libcurl4 wget curl &> /dev/null

# 2. Pedir la Key
echo -ne "\e[1;33m🔑 INGRESE SU LLAVE DE ACTIVACIÓN: \e[0m"
read KEY
HWID=$(cat /etc/machine-id 2>/dev/null | cut -c1-10)

# 3. Validar con tu servidor (DNS)
SVR="prueba.red-pro.site"
CHECK=$(curl -s "http://$SVR/licencias/validar.php?key=$KEY&hwid=$HWID")

if [[ "$CHECK" == "OK" ]]; then
    echo -e "\e[1;32m[+] Licencia Válida.\e[0m"
    
    # 4. Descargar y decodificar el binario (CORREGIDO PARA BASE64)
    # Bajamos el texto de GitHub y lo transformamos en el archivo original de 23K
    curl -sL "https://raw.githubusercontent.com/6274-W/panel-licencias/main/core_engine" | base64 -d > /usr/local/bin/panel
    chmod +x /usr/local/bin/panel
    
    # Crear el comando 'panel'
    if ! grep -q "alias panel" ~/.bashrc; then
        echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    fi
    source ~/.bashrc &> /dev/null
    
    echo -e "\e[1;32m[+] TODO LISTO. Escriba '\e[1;33mpanel\e[1;32m' para empezar.\e[0m"
else
    # Si el servidor no responde OK, muestra el error (KEY_INVALIDA, etc.)
    echo -e "\e[1;31m[!] Error: $CHECK\e[0m"
    exit 1
fi
