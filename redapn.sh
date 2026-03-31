#!/bin/bash
# --- CONFIGURACIÓN ---
IP_MAESTRA="166.1.88.72" # <--- PON LA IP DE TU VPS MAESTRA
URL_PANEL="https://raw.githubusercontent.com/6274-W/panel-licencias/main/redapn.sh"

clear
echo -e "\e[1;36m🛡️ VERIFICACIÓN DE LICENCIA RED APN PRO\e[0m"
echo -ne "\e[1;33mIntroduce tu Key: \e[0m"
read user_key

# Validar contra tu VPS
status=$(curl -s -d "key=$user_key" "http://$IP_MAESTRA/licencias/validar.php")

if [ "$status" == "OK" ]; then
    echo -e "\e[1;32m✅ Acceso concedido. Instalando...\e[0m"
    mkdir -p /etc/redapn
    wget -qO /usr/local/bin/panel "$URL_PANEL"
    chmod +x /usr/local/bin/panel
    echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    echo -e "\e[1;32m🚀 Instalación lista. Escribe 'panel'\e[0m"
else
    echo -e "\e[1;31m❌ Key inválida o ya utilizada.\e[0m"
    exit 1
fi
