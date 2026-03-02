#!/bin/bash

# ==============================================================================
# NOMBRE: backup-synaptik.sh
# PROPÓSITO: "Ctrl+Z" de emergencia. Crea respaldo de la carpeta Synaptik 
#            y conserva estrictamente los 2 más recientes.
# ==============================================================================

# 1. CONFIGURACIÓN DE RUTAS 
RUTA_SYNAPTIK="/media/luxce2/Kingston/synaptik-lite"
RUTA_RESPALDOS="$HOME/respaldos_synaptik"

# 2. PREPARACIÓN
FECHA=$(date +'%Y-%m-%d_%H-%M-%S')
NOMBRE_ARCHIVO="synaptik_backup_$FECHA.tar.gz"

echo "📦 Guardando punto de restauración de Synaptik..."
mkdir -p "$RUTA_RESPALDOS"

# 3. COMPRESIÓN
if tar -czf "$RUTA_RESPALDOS/$NOMBRE_ARCHIVO" -C "$(dirname "$RUTA_SYNAPTIK")" "$(basename "$RUTA_SYNAPTIK")"; then
    echo "✅ Respaldo de emergencia listo: $NOMBRE_ARCHIVO"
else
    echo "❌ Error al crear el respaldo."
    exit 1
fi

# 4. LIMPIEZA AUTOMÁTICA (Mantiene solo 2)
# ------------------------------------------------------------------------------
echo "🧹 Revisando el historial de respaldos..."

# Cuenta cuántos archivos hay
CANTIDAD=$(ls -1 "$RUTA_RESPALDOS"/*.tar.gz 2>/dev/null | wc -l)

if [ "$CANTIDAD" -gt 2 ]; then
    # Ordena por fecha (más nuevo arriba) y borra desde el 3ro en adelante
    ls -t "$RUTA_RESPALDOS"/*.tar.gz | tail -n +3 | xargs rm -f
    echo "♻️  Limpieza aplicada. Tienes tus 2 respaldos más recientes listos."
else
    echo "ℹ️  Hay $CANTIDAD respaldo(s) en total. Todo en orden."
fi

echo "🏁 Proceso finalizado. ¡Puedes romper el código tranquilo! xd"