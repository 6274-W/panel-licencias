#!/bin/bash
# --- CONFIGURACIÓN ---
IP_MAESTRA="166.1.88.72" # <--- ASEGÚRATE DE QUE SEA LA 166...
URL_PANEL="https://raw.githubusercontent.com/6274-W/panel-licencias/main/redapn.sh"

# --- COLORES ---
G='\e[1;32m'; R='\e[1;31m'; Y='\e[1;33m'; NC='\e[0m'; C='\e[1;36m'

clear
echo -e "${C}┌──────────────────────────────────────────┐${NC}"
echo -e "${C}│${NC}        ${Y}🚀 RED APN PRO - ACTIVACIÓN 🚀${NC}      ${C}│${NC}"
echo -e "${C}└──────────────────────────────────────────┘${NC}"
echo ""
echo -ne "${Y}🔑 INGRESE SU KEY DE ACCESO: ${NC}"
read user_key

# Validación mediante POST a tu VPS
# Usamos --data para enviar la key correctamente
status=$(curl -s --data "key=$user_key" "http://$IP_MAESTRA/licencias/validar.php")

if [ "$status" == "OK" ]; then
    echo -e "\n${G}✅ LICENCIA AUTORIZADA.${NC}"
    echo -e "${C}📥 Descargando componentes...${NC}"
    
    apt update && apt install -y curl wget at > /dev/null 2>&1
    mkdir -p /etc/redapn
    
    wget -qO /usr/local/bin/panel "$URL_PANEL"
    chmod +x /usr/local/bin/panel
    
    # Crear el comando 'panel'
    if ! grep -q "alias panel" ~/.bashrc; then
        echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    fi
    
    echo -e "\n${G}⭐ ¡INSTALACIÓN EXITOSA!${NC}"
    echo -e "${W}Escriba ${Y}panel${W} para iniciar el sistema.${NC}"
else
    echo -e "\n${R}❌ KEY INVÁLIDA O YA UTILIZADA.${NC}"
    echo -e "${Y}Verifica que la Key sea correcta o solicita una nueva.${NC}"
    exit 1
fi
