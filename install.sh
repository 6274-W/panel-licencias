#!/bin/bash
clear
rm -rf $0 &> /dev/null

echo -e "\e[1;32m[+] Instalador RED APN PRO\e[0m"

apt update -y &> /dev/null
apt install -y curl wget &> /dev/null

echo -ne "\e[1;33m🔑 INGRESE SU KEY: \e[0m"
read KEY

HWID=$(cat /etc/machine-id | cut -c1-10)

SVR="prueba.red-pro.site"  # ← CAMBIALO

CHECK=$(curl -s "http://$SVR/licencias/validar.php?key=$KEY&hwid=$HWID")

if [[ "$CHECK" == "OK" ]]; then
    echo -e "\e[1;32m✔ Licencia válida\e[0m"

    wget -q -O /usr/local/bin/panel "http://$SVR/licencias/download.php?key=$KEY"

    chmod +x /usr/local/bin/panel
    echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc

    echo -e "\e[1;32m✔ Instalado. Usa: panel\e[0m"
else
    echo -e "\e[1;31m✘ $CHECK\e[0m"
    exit 1
fi
