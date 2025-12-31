🔐 Auditoría de Seguridad Avanzada en Linux (Bash)

He desarrollado un script de auditoría de seguridad avanzada que automatiza la detección de riesgos críticos en sistemas Linux:
✔ Rootkits

✔ Integridad de binarios

✔ Usuarios y privilegios anómalos

✔ Backdoors y conexiones activas

✔ Hardening del kernel

✔ Análisis de logs y persistencia

El script genera un informe detallado y lo notifica automáticamente por correo y Telegram, facilitando la monitorización continua y la respuesta temprana ante incidentes.

Automatización, visibilidad y seguridad real.

🔐Pasos para ponerlo en funcionamiento:

1️⃣ Crear el archivo
sudo nano /usr/local/sbin/SegAvanzada.sh
✔ Pega todo el contenido del script
✔ Guarda con CTRL + O
✔ Sal con CTRL + X
2️⃣ Dar permisos correctos (OBLIGATORIO)
sudo chmod 750 /usr/local/sbin/SegAvanzada.sh
3️⃣ Asignar propietario (recomendado)
sudo chown root:root /usr/local/sbin/SegAvanzada.sh
4️⃣ Verificar que existe y es ejecutable
ls -l /usr/local/sbin/SegAvanzada.sh
✔ Debe verse algo parecido a:
-rwxr-x--- 1 root root ... SegAvanzada.sh
5️⃣ Ejecutar el script manualmente
sudo /usr/local/sbin/SegAvanzada.sh
6️⃣ Comprobar que se generó el informe
ls -l ~/auditoria_seguridad_avanzada_*.log
7️⃣ Verificar envío por Telegram y correo
✔ Telegram: debe llegarte el archivo
✔ Email: revisa la bandeja del destinatario configurado
✔ Si no llega el correo, prueba:
which msmtp
8️⃣ (Opcional) Ejecutarlo automáticamente con cron
✔ Editar cron de root:
sudo crontab -e
✔ Añadir esta línea:
0 3 * * 0 /usr/local/sbin/SegAvanzada.sh
