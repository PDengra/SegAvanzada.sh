#!/bin/bash
# ============================================
# Auditoría de Seguridad Avanzada en Linux (Bash)
# Autor: Pablo Dengra
# Fecha: $(date +"%Y-%m-%d")
# ============================================

# ============================
# Variables
# ============================
INFORME="$HOME/auditoria_seguridad_avanzada_$(date +%Y%m%d).log"

# --- Email ---
EMAIL="admin@tuservidor.com"

# --- Telegram ---
TELEGRAM_BOT_TOKEN="AQUI_TU_TOKEN"
TELEGRAM_CHAT_ID="AQUI_TU_CHAT_ID"

HOSTNAME=$(hostname)
FECHA=$(date)

# ============================
# Cabecera
# ============================
{
echo "============================================"
echo " AUDITORÍA DE SEGURIDAD AVANZADA - $FECHA"
echo " Host: $HOSTNAME"
echo "============================================"
} > "$INFORME"

# ============================
# 1. Comprobación de Rootkits
# ============================
echo -e "\n[+] Comprobación de rootkits:" >> "$INFORME"
if command -v rkhunter &>/dev/null; then
    rkhunter --check --sk --rwo >> "$INFORME"
else
    echo "rkhunter no instalado" >> "$INFORME"
fi

# ============================
# 2. Integridad de binarios críticos
# ============================
echo -e "\n[+] Checksums de binarios críticos:" >> "$INFORME"
for bin in /bin/ls /bin/bash /usr/bin/sudo /usr/bin/passwd; do
    [[ -f "$bin" ]] && sha256sum "$bin" >> "$INFORME"
done

# ============================
# 3. Permisos inseguros en /etc
# ============================
echo -e "\n[+] Archivos inseguros en /etc:" >> "$INFORME"
find /etc -type f \( -perm -002 -o -perm -020 \) 2>/dev/null >> "$INFORME"

# ============================
# 4. Usuarios sin contraseña
# ============================
echo -e "\n[+] Usuarios sin contraseña:" >> "$INFORME"
awk -F: '($2==""){print $1}' /etc/shadow 2>/dev/null >> "$INFORME"

# ============================
# 5. UID 0 adicionales
# ============================
echo -e "\n[+] Usuarios con UID 0:" >> "$INFORME"
awk -F: '($3==0){print $1}' /etc/passwd >> "$INFORME"

# ============================
# 6. Backdoors comunes
# ============================
echo -e "\n[+] Backdoors conocidos (netcat, socat):" >> "$INFORME"
ps aux | grep -E "nc|netcat|socat" | grep -v grep >> "$INFORME"

# ============================
# 7. Conexiones de red activas
# ============================
echo -e "\n[+] Conexiones de red activas:" >> "$INFORME"
ss -atunp >> "$INFORME"

# ============================
# 8. Binarios modificados recientemente
# ============================
echo -e "\n[+] Binarios modificados (7 días):" >> "$INFORME"
find /bin /sbin /usr/bin /usr/sbin -mtime -7 2>/dev/null >> "$INFORME"

# ============================
# 9. Servicios sospechosos
# ============================
echo -e "\n[+] Servicios sospechosos:" >> "$INFORME"
systemctl list-units --type=service --state=running | grep -Ei "nc|ftp|telnet|rpcbind" >> "$INFORME"

# ============================
# 10. Logs críticos
# ============================
echo -e "\n[+] Eventos críticos:" >> "$INFORME"
grep -Ei "failed|error|invalid|authentication failure" \
    /var/log/auth.log /var/log/secure 2>/dev/null | tail -n 20 >> "$INFORME"

# ============================
# 11. Variables de entorno peligrosas
# ============================
echo -e "\n[+] Variables de entorno sensibles:" >> "$INFORME"
env | grep -Ei "LD_PRELOAD|LD_LIBRARY_PATH" >> "$INFORME"

# ============================
# 12. Archivos ocultos
# ============================
echo -e "\n[+] Archivos ocultos sospechosos:" >> "$INFORME"
find /root /tmp -name ".*" 2>/dev/null >> "$INFORME"

# ============================
# 13. Contenedores
# ============================
echo -e "\n[+] Docker / Podman:" >> "$INFORME"
command -v docker &>/dev/null && docker ps -a >> "$INFORME" || echo "Docker no detectado" >> "$INFORME"

# ============================
# 14. Kernel hardening
# ============================
echo -e "\n[+] Hardening del kernel:" >> "$INFORME"
sysctl -a 2>/dev/null | grep -E "randomize_va_space|kptr_restrict|dmesg_restrict" >> "$INFORME"

# ============================
# Final
# ============================
{
echo
echo "============================================"
echo " Auditoría avanzada finalizada"
echo " Informe: $INFORME"
echo "============================================"
} >> "$INFORME"

# ============================
# Envío por EMAIL
# ============================
if command -v msmtp &>/dev/null; then
    {
        echo "Subject: Auditoría de Seguridad AVANZADA - $HOSTNAME"
        echo "To: $EMAIL"
        echo "Content-Type: text/plain; charset=UTF-8"
        echo
        cat "$INFORME"
    } | msmtp "$EMAIL"
fi

# ============================
# Envío por TELEGRAM
# ============================
if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" \
        -F chat_id="$TELEGRAM_CHAT_ID" \
        -F document=@"$INFORME" \
        -F caption="🔐 Auditoría AVANZADA completada en $HOSTNAME"
fi
