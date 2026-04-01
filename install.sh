#!/bin/bash
# --- CONFIGURACIÓN ---
IP_MAESTRA="166.1.88.72" 
# URL del archivo de texto con el código Base64
URL_TXT="https://raw.githubusercontent.com/6274-W/panel-licencias/main/redapn.txt"
AUTH_FILE="/etc/redapn/auth_token"

# --- COLORES ---

clear
echo -e "${C}┌──────────────────────────────────────────┐${NC}"
echo -e "${C}│${NC}        ${Y}🚀 RED APN PRO - SISTEMA 🚀${NC}         ${C}│${NC}"
echo -e "${C}└──────────────────────────────────────────┘${NC}"

# 1. Verificar si ya está validado localmente
if [ -f "$AUTH_FILE" ]; then
    echo -e "\n${G}✅ LICENCIA ACTIVA DETECTADA.${NC}"
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
    
    # Crear carpeta y asegurar dependencias
    mkdir -p /etc/redapn
    apt update && apt install -y curl wget coreutils > /dev/null 2>&1
    
    echo -e "${C}📥 Descargando y Decodificando Panel PRO...${NC}"
    
    # PASO CLAVE: Descarga el texto y lo convierte en el binario real
    wget -qO /etc/redapn/redapn.txt "$URL_TXT"
    base64 -d /etc/redapn/redapn.txt > /usr/local/bin/panel
    
    # Asignar permisos de ejecución al binario
    chmod +x /usr/local/bin/panel
    
    # Guardar Token de Sesión (Persistencia)
    echo "$user_key" > "$AUTH_FILE"
    chmod 444 "$AUTH_FILE"
    
    # Limpieza del archivo temporal
    rm -f /etc/redapn/redapn.txt

    # Crear alias para que funcione el comando 'panel'
    if ! grep -q "alias panel" ~/.bashrc; then
        echo "alias panel='/usr/local/bin/panel'" >> ~/.bashrc
    fi
    
    echo -e "\n${G}⭐ ¡INSTALACIÓN EXITOSA!${NC}"
    echo -e "${W}Escriba ${Y}panel${W} para iniciar.${NC}"
    
    # Forzar actualización de alias en la sesión actual
    export PATH=$PATH:/usr/local/bin
    source ~/.bashrc
else
    echo -e "\n${R}❌ ERROR: $status${NC}"
    echo -e "${Y}La Key es incorrecta o ya está vinculada a otro equipo.${NC}"
    exit 1
fi
