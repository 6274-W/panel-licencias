#!/bin/bash

clear
echo "======================================"
echo "      🔐 RED APN PRO INSTALLER"
echo "======================================"

# --- PEDIR LICENCIA ---
read -p "🔑 Ingresa tu licencia: " LIC

# --- VALIDAR CONTRA TU VPS ---
RESP=$(curl -s "https://166.1.90.181/validar.php?licencia=$LIC")

if  "$RESP" != *"OK"* ; then
    echo "❌ Licencia inválida"
    exit 1
fi

echo "✅ Licencia válida"
echo "🚀 Instalando..."

# --- DEPENDENCIAS ---
apt update -y
apt install -y curl iptables at lsb-release

# --- DIRECTORIOS ---
mkdir -p /etc/redapn

# --- CREAR PANEL ---
cat << 'EOF' > /root/redapn.sh

#!/bin/bash

# --- 1. PALETA DE COLORES ANSI (ESTILO HACKER) ---
R='\e[1;31m'; G='\e[1;32m'; Y='\e[1;33m'; B='\e[1;34m'; M='\e[1;35m'; C='\e[1;36m'; W='\e[1;37m'; NC='\e[0m'

# --- RUTAS ---
mkdir -p /etc/redapn
DB="/etc/redapn/usuarios.db"
TG_CONF="/etc/redapn/tg.conf"
PORT_DB="/etc/redapn/puertos.db"
[ ! -f "$DB" ] && touch "$DB"
[ ! -f "$PORT_DB" ] && echo "SSH:22|SSL:443|Dropbear:80|Squid:8080" > "$PORT_DB"

# --- 2. EXTRACCIÓN DE DATOS (PARSING) ---
get_info() {
    SO=$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2 | awk '{print $1,$2}')
    IP=$(curl -s eth0.me || echo "IP-Private")
    FECHA=$(date +%d/%m/%Y)
    HORA=$(date +%H:%M:%S)
    # RAM
    RAM_T=$(free -h | awk '/Mem:/ {print $2}')
    RAM_U=$(free -h | awk '/Mem:/ {print $3}')
    RAM_L=$(free -h | awk '/Mem:/ {print $4}')
    RAM_B=$(free -h | awk '/Mem:/ {print $6}')
    RAM_C=$(free -h | awk '/Mem:/ {print $7}')
    # DISCO
    DSK_T=$(df -h / | awk 'NR==2 {print $2}')
    DSK_U=$(df -h / | awk 'NR==2 {print $3}')
    DSK_L=$(df -h / | awk 'NR==2 {print $4}')
    # CPU
    CPU_C=$(nproc)
    CPU_U=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')"%"
}

# --- 3. HEADER (CONSTRUCCIÓN TUI PROFESIONAL) ---
header() {
    get_info
    clear
    echo -e "${C}┌───────────────────────────────────────────┐${NC}"
    echo -e "${C}│${NC}   ${Y}🔥✨  RED APN PRO — SISTEMA ELITE  ✨🔥${NC}   ${C}│${NC}"
    echo -e "${C}├───────────────────────────────────────────┤${NC}"
    echo -e " ${W}💻 S.O: ${G}$SO${NC}  ${W}🌐 IP: ${G}$IP${NC}"
    echo -e " ${W}📅 FEC: ${G}$FECHA${NC}  ${W}⏰ HOR: ${Y}$HORA${NC}"
    echo -e "${C}├─────────────────────┬─────────────────────┤${NC}"
    echo -e " ${M}   DISCO (GB)       ${C}│${M}      CPU / RAM      ${NC}"
    echo -e " ${W}Total:  ${G}$DSK_T${NC}       ${C}│${W} Cores:  ${G}$CPU_C${NC}"
    echo -e " ${W}En Uso: ${R}$DSK_U${NC}       ${C}│${W} En Uso: ${R}$CPU_U${NC}"
    echo -e " ${W}Libre:  ${G}$DSK_L${NC}       ${C}│${W} RAM T:  ${G}$RAM_T${NC}"
    echo -e "${C}├─────────────────────┴─────────────────────┤${NC}"
    echo -e " ${W}RAM U: ${R}$RAM_U${W} | L: ${G}$RAM_L${W} | B: ${B}$RAM_B${W} | C: ${B}$RAM_C${NC}"
    echo -e "${C}└───────────────────────────────────────────┘${NC}"
}

# --- 4. MONITOR MAESTRO (TELEGRAM + LÍMITES + DATOS) ---
monitor_maestro() {
    declare -A inicio_sesion
    while true; do
        while IFS='|' read -r u p e l; do
            count=$(ps -u "$u" 2>/dev/null | grep -cE "sshd|dropbear")
            # Límite estricto
            if [ "$count" -gt "$l" ]; then pkill -u "$u" -n > /dev/null 2>&1; fi
            # Login Notification
            if  "$count" -gt 0 && -z "${inicio_sesion[$u]}" ; then
                inicio_sesion[$u]=$(date +%s)
                iptables -N "$u" 2>/dev/null
                iptables -I FORWARD -m owner --uid-owner "$u" -j "$u" 2>/dev/null
                MSG="🚀 *LOGIN:* \`$u\`%0A🚀 *LIMITE:* $l%0A⏰ *HORA:* $(date +%H:%M)"
                send_tg "$MSG"
            # Logout Notification + Consumo
            elif  "$count" -eq 0 && -n "${inicio_sesion[$u]}" ; then
                fin=$(date +%s); dur=$(( (fin - inicio_sesion[$u]) / 60 ))
                cons=$(iptables -L FORWARD -n -v | grep -w "$u" | awk '{print $2}' | head -n 1)
                iptables -D FORWARD -m owner --uid-owner "$u" -j "$u" 2>/dev/null
                iptables -X "$u" 2>/dev/null
                MSG="🔴 *LOGOUT:* \`$u\`%0A⏳ *TIEMPO:* $dur min%0A📊 *CONSUMO:* $cons"
                send_tg "$MSG"
                unset inicio_sesion[$u]
            fi
        done < "$DB"
        sleep 5
    done
}
if ! pgrep -f "monitor_maestro" > /dev/null; then (monitor_maestro &) > /dev/null 2>&1; fi

send_tg() {
    [ -f "$TG_CONF" ] && source "$TG_CONF"
    if  -n "$TOKEN" ; then
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID&text=$1&parse_mode=Markdown" > /dev/null
    fi
}

# --- 5. FUNCIONES DEL PANEL ---
crear_usuario() {
    header
    echo -e " ${Y}👤 CREAR NUEVO USUARIO${NC}"
    echo -ne " ${W}USER: ${NC}"; read usr
    echo -ne " ${W}PASS: ${NC}"; read pass
    echo -ne " ${W}DIAS: ${NC}"; read dias
    echo -ne " ${W}LIMI: ${NC}"; read limit
    echo -e "${C}───────────────────────────────────────────${NC}"
    echo -e " ${G}[ENTER] Guardar${NC} | ${R}[C] Cancelar${NC} | ${Y}[I] Intentar${NC}"
    read op
    case $op in
        [Cc]*) return ;;
        [Ii]*) crear_usuario ;;
        *)
            exp=$(date -d "$dias days" +"%Y-%m-%d")
            useradd -M -s /bin/false -e "$exp" "$usr" && echo "$usr:$pass" | chpasswd
            echo "$usr|$pass|$exp|$limit" >> "$DB"
            MSG="💎 *RED APN PRO - VENTA* 💎%0A━━━━━━━━━━━━━━━%0A👤 *USER:* \`$usr\`%0A🔑 *PASS:* \`$pass\`%0A🚀 *LIMITE:* $limit%0A📅 *EXPIRA:* $exp%0A⌛ *QUEDAN:* $dias Días%0A━━━━━━━━━━━━━━━"
            send_tg "$MSG"
            echo -e "${G}✔ Usuario creado y enviado a Telegram.${NC}"; sleep 2 ;;
    esac
}

usuarios_temporales() {
    header
    echo -e " ${Y}⏳ CREAR DEMO (TEMPORAL)${NC}"
    echo -e " ${W}Ejemplo: 1hs, 2hs, 24hs${NC}"
    echo -ne " ${W}USER: ${NC}"; read tu
    echo -ne " ${W}PASS: ${NC}"; read tp
    echo -ne " ${W}TIEMPO (hs): ${NC}"; read th
    useradd -M -s /bin/false "$tu" && echo "$tu:$tp" | chpasswd
    echo "userdel -f $tu" | at now + "$th" hours
    echo -e "${G}✔ El usuario se eliminará en $th horas.${NC}"; sleep 2
}

administrar_puertos() {
    header
    echo -e " ${Y}⚙️ ADMINISTRACIÓN DE PUERTOS${NC}"
    echo -e " ${B}[1]${W} Squid  ${B}[2]${W} Apache ${B}[3]${W} SSH"
    echo -e " ${B}[4]${W} Dropb  ${B}[5]${W} SSL    ${B}[6]${W} Activar UDP"
    echo -e " ${B}[7]${W} BADVPN ${B}[8]${W} Ver Activos"
    echo -ne "\n ${Y}Selección:${NC} "; read po
    case $po in
        6) iptables -I INPUT -p udp --dport 7300 -j ACCEPT; echo "UDP:7300|" >> "$PORT_DB"; echo -e "${G}✔ UDP 7300 Activo.${NC}"; sleep 2 ;;
        8) header; echo -e "${G}PUERTOS CONFIGURADOS:${NC}"
           tr '|' '\n' < "$PORT_DB"; read -p "Enter..." ;;
        *) echo -ne "Agregue su puerto: "; read n_puerto
           iptables -I INPUT -p tcp --dport $n_puerto -j ACCEPT
           echo "Custom:$n_puerto|" >> "$PORT_DB"; sleep 1 ;;
    esac
}

lista_usuarios() {
    header
    echo -e " ${Y}📋 LISTA DE USUARIOS (TOTAL: $(wc -l < $DB))${NC}"
    printf "${W}%-10s | %-8s | %-10s | %-2s${NC}\n" "USER" "PASS" "VENCE" "LIM"
    echo -e "${C}───────────────────────────────────────────${NC}"
    while IFS='|' read -r u p e l; do
        printf "👤 %-8s | %-8s | %-10s | %-2s\n" "$u" "$p" "$e" "$l"
    done < "$DB"
    read -p "Presione Enter..."
}

monitor_online() {
    header
    echo -e "${G}   CONECTADOS (ON)         ${R}DESCONECTADOS (OFF)${NC}"
    echo -e "${C}───────────────────────────────────────────${NC}"
    c_on=0; c_off=0
    while IFS='|' read -r u p e l; do
        on=$(ps -u "$u" | grep -cE "sshd|dropbear")
        if [ "$on" -gt 0 ]; then
            echo -e " ${G}✔ %-15s (Activo)${NC}" "$u"
            ((c_on++))
        else
            echo -e " ${R}✘ %-15s (Offline)${NC}" "$u"
            ((c_off++))
        fi
    done < "$DB"
    echo -e "${C}─────────────────────┬─────────────────────┤${NC}"
    echo -e " ${G}TOTAL ON: $c_on${NC}      │ ${R}TOTAL OFF: $c_off${NC}"
    read -p "Enter para volver..."
}

renovar_usuario() {
    header
    echo -e " ${Y}♻️ RENOVAR USUARIO${NC}"
    nl -s ") " "$DB" | awk -F'|' '{print $1 " [Vence: "$3"]"}'
    read -p "Número de ID: " num
    linea=$(sed -n "${num}p" "$DB")
    if [ -n "$linea" ]; then
        u=$(echo "$linea" | cut -d'|' -f1); p=$(echo "$linea" | cut -d'|' -f2); l=$(echo "$linea" | cut -d'|' -f4)
        read -p "Nuevos días: " nd
        n_exp=$(date -d "$nd days" +"%Y-%m-%d")
        chage -E "$n_exp" "$u"
        sed -i "${num}s/.*/$u|$p|$n_exp|$l/" "$DB"
        echo -e "${G}✔ Renovado.${NC}"; sleep 2
    fi
}

# --- 6. MENÚ PRINCIPAL (DOS COLUMNAS) ---
while true; do
    header
    echo -e "  ${B}[1]${W} Crear Usuario     ${B}[2]${W} User Temporal ⏳"
    echo -e "  ${B}[3]${W} Banner SSH 🚩     ${B}[4]${W} Puertos/Serv ⚙️"
    echo -e "  ${B}[5]${W} Lista Usuarios 📋 ${B}[6]${W} Ver Online 🟢"
    echo -e "  ${B}[7]${W} Renovar User ♻️    ${B}[8]${W} Eliminar User 🗑️"
    echo -e "  ${B}[9]${W} Config Telegram 🤖 ${B}[10]${W} Editar TG 📝"
    echo -e "  ${B}[P]${W} Auto-Inicio 🔥    ${B}[0]${W} Salir del Panel"
    echo -e "${C}───────────────────────────────────────────${NC}"
    echo -ne " ${Y}╰──> Opción:${NC} "; read opt

    case $opt in
        1) crear_usuario ;;
        2) usuarios_temporales ;;
        3) header; read -p "Escribe tu banner: " b; echo "$b" > /etc/redapn/banner; echo "Banner activo." ; sleep 2 ;;
        4) administrar_puertos ;;
        5) lista_usuarios ;;
        6) monitor_online ;;
        7) renovar_usuario ;;
        8) header; nl -s ") " "$DB"; read -p "ID a eliminar: " id; u_d=$(sed -n "${id}p" "$DB" | cut -d'|' -f1); userdel -f "$u_d"; sed -i "${id}d" "$DB"; sleep 1 ;;
        9|10) header; read -p "Token: " tk; read -p "ID: " idt; echo -e "TOKEN=$tk\nID=$idt" > "$TG_CONF";;
        [Pp]*) echo "bash $(pwd)/redapn.sh" >> ~/.bashrc; alias panel="bash $(pwd)/redapn.sh"; echo "Fijado."; sleep 1 ;;
        0) clear; exit 0 ;;
    esac
done


EOF

chmod +x /root/redapn.sh

# --- ALIAS ---
echo "alias panel='bash /root/redapn.sh'" >> ~/.bashrc
source ~/.bashrc

echo ""
echo "======================================"
echo "✅ Instalación completa"
echo "👉 Ejecuta: panel"
echo "======================================"
