#!/bin/bash
# --- CONFIGURACIÓN ---
IP_MAESTRA="166.1.88.72" 
URL_PANEL="https://raw.githubusercontent.com/6274-W/panel-licencias/main/redapn.sh"
AUTH_FILE="/etc/redapn/auth_token"

# --- COLORES ---
G='\e[1;32m'; R='\e[1;31m'; Y='\e[1;33m'; NC='\e[0m'; C='\e[1;36m'; W='\e[1;37m'

clear
echo -e "${C}┌──────────────────────────────────────────┐${NC}"
echo -e "${C}│${NC}        ${Y}🚀 RED APN PRO - SISTEMA 🚀${NC}         ${C}│${NC}"
echo -e "${C}└──────────────────────────────────────────┘${NC}"

# 1. Verificar si ya está validado localmente
if [ -f "$AUTH_FILE" ]; then
    echo -e "\n${G}✅ LICENCIA ACTIVA DETECTADA.${NC}"
    # Si ya existe el panel, lo ejecutamos, si no lo descargamos de nuevo
    if [ -f /usr/local/bin/panel ]; then
        panel
        exit 0
    fi
fi

# 2. Proceso de Activación
echo -ne "\n${Y}🔑 INGRESE SU KEY DE ACCESO: ${NC}"
read user_key

if [ -z "$user_key" ]; then echo -e "${R}Key vacía.${NC}"; exit 1; fi

HWID=$(cat /etc/machine-id | cut -c1-10)

echo -e "${C}[*] Verificando con servidor central...${NC}"
status=$(curl -s --data "key=$user_key&hwid=$HWID" "http://$IP_MAESTRA/licencias/validar.php")

if [ "$status" == "OK" ]; then
    echo -e "${G}✅ ACCESO CONCEDIDO.${NC}"
    
    # Crear carpeta y guardar el "Token de Sesión" (Persistencia)
    mkdir -p /etc/redapn
    echo "$user_key" > "$AUTH_FILE"
    chmod 444 "$AUTH_FILE"

    # Instalación de componentes
    apt update && apt install -y curl wget > /dev/null 2>&1
    
    echo -e "${C}📥 Descargando Panel Principal...${NC}"
    wget -qO /usr/local/bin/panel "$URL_PANEL"
    chmod +x /usr/local/bin/panel
    
    # Crear alias para que funcione el comando 'panel'
    if ! grep -q "alias panel" ~/.bashrc; then
        echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    fi
    
    echo -e "\n${G}⭐ ¡INSTALACIÓN EXITOSA!${NC}"
    echo -e "${W}Escriba ${Y}panel${W} para iniciar.${NC}"
    source ~/.bashrc
else
    echo -e "\n${R}❌ ERROR: $status${NC}"
    echo -e "${Y}La Key es incorrecta o ya está vinculada a otro equipo.${NC}"
    exit 1
fi
