#!/bin/bash

# ==============================================================================
# NOMBRE: backup-synaptik.sh
# PROPÓSITO: "Ctrl+Z" de emergencia. Respalda Synaptik (incluyendo DB protegida)
#            y conserva estrictamente los 2 más recientes en el disco principal.
# ==============================================================================

# 1. VERIFICACIÓN DE SEGURIDAD (ROOT)
# ------------------------------------------------------------------------------
# Necesitamos ser root para leer la carpeta de datos de Postgres en Docker.
if [ "$EUID" -ne 0 ]; then 
  echo "🚫 Error: Se requieren permisos de superusuario."
  echo "👉 Usa: sudo save-synaptik"
  exit 1
fi

# 2. CONFIGURACIÓN DE RUTAS
# ------------------------------------------------------------------------------
# Ruta donde vive el proyecto (Disco Kingston)
RUTA_SYNAPTIK="/media/luxce2/Kingston/synaptik-lite"

# Ruta donde guardamos los salvavidas (Disco Principal)
# IMPORTANTE: Usamos la ruta completa porque con sudo, $HOME podría fallar.
RUTA_RESPALDOS="/home/luxce2/respaldos_synaptik"

# 3. PREPARACIÓN DEL ARCHIVO
# ------------------------------------------------------------------------------
FECHA=$(date +'%Y-%m-%d_%H-%M-%S')
NOMBRE_ARCHIVO="synaptik_backup_$FECHA.tar.gz"

echo "📦 Iniciando respaldo total de Synaptik (incluyendo .env y bases de datos)..."
mkdir -p "$RUTA_RESPALDOS"

# 4. COMPRESIÓN (EL CORAZÓN DEL SCRIPT)
# ------------------------------------------------------------------------------
# -C cambia de directorio antes de comprimir para que el zip no tenga rutas infinitas.
if tar -czf "$RUTA_RESPALDOS/$NOMBRE_ARCHIVO" -C "$(dirname "$RUTA_SYNAPTIK")" "$(basename "$RUTA_SYNAPTIK")"; then
    echo "✅ Respaldo creado: $NOMBRE_ARCHIVO"
    
    # 5. AJUSTE DE PERMISOS
    # Como usamos sudo, el archivo nace siendo de 'root'. Lo devolvemos a 'luxce2'.
    chown luxce2:luxce2 "$RUTA_RESPALDOS/$NOMBRE_ARCHIVO"
    echo "👤 Propiedad del archivo devuelta a tu usuario."
else
    echo "❌ Error crítico: No se pudo crear el archivo comprimido."
    exit 1
fi

# 6. LIMPIEZA AUTOMÁTICA (MANTIENE SOLO 2)
# ------------------------------------------------------------------------------
echo "🧹 Revisando el historial de puntos de restauración..."

# Contamos cuántos archivos tar.gz hay en la carpeta de respaldos
CANTIDAD=$(ls -1 "$RUTA_RESPALDOS"/*.tar.gz 2>/dev/null | wc -l)

if [ "$CANTIDAD" -gt 2 ]; then
    # ls -t ordena por fecha (nuevo arriba). 
    # tail -n +3 toma todo lo que esté de la tercera línea hacia abajo para borrarlo.
    ls -t "$RUTA_RESPALDOS"/*.tar.gz | tail -n +3 | xargs rm -f
    echo "♻️  Limpieza terminada. Tienes los 2 respaldos más recientes listos para el rescate."
else
    echo "ℹ️  Historial limpio: Tienes $CANTIDAD respaldo(s)."
fi

echo "----------------------------------------------------"
echo "🏁 ¡Listo! Puedes editar en 'hot' sin miedo al éxito. xd"
echo "----------------------------------------------------"