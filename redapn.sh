#!/bin/bash
# --- SEGURO DE LICENCIA ---
if [ ! -f /etc/redapn/auth_token ]; then
    echo "Acceso denegado. No se encontró licencia activa."
    exit 1
fi

clear
echo -e "\033[1;32m   ___  _______  ___    ___  _  __ PRO\033[0m"
echo -e "\033[1;32m  / _ \/ __/ _ \/ _ |  / _ \/ |/ /\033[0m"
echo -e "\033[1;32m / , _/ _// // / __ | / ___/    / \033[0m"
echo -e "\033[1;32m/_/|_/___/____/_/ |_|/_/  /_/|_/  \033[0m"
echo "-----------------------------------------------"
echo "1). Iniciar Servicio VPN"
echo "2). Gestionar Usuarios"
echo "3). Optimizar Servidor"
echo "4). Salir"
echo "-----------------------------------------------"
echo -n "Seleccione una opción: "
read opcion

case $opcion in
    1) echo "Iniciando...";;
    2) echo "Usuarios activos...";;
    3) apt autoremove -y && apt clean;;
    4) exit 0;;
    *) echo "Opción inválida";;
esac
