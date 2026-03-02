#!/bin/bash

# ==============================================================================
# NOMBRE: restore-synaptik.sh
# PROPÓSITO: El "Ctrl+Z" definitivo. Restaura el último backup de Synaptik
#            en el disco Kingston usando permisos de superusuario.
# ==============================================================================

# 1. VERIFICACIÓN DE SEGURIDAD (ROOT)
if [ "$EUID" -ne 0 ]; then 
  echo "🚫 Error: Se requieren permisos de superusuario para restaurar."
  echo "👉 Usa: sudo restore-synaptik"
  exit 1
fi

# 2. CONFIGURACIÓN DE RUTAS
RUTA_DESTINO="/media/luxce2/Kingston" 
RUTA_RESPALDOS="/home/luxce2/respaldos_synaptik"

echo "----------------------------------------------------"
echo "🚨 INICIANDO RESTAURACIÓN DE EMERGENCIA"
echo "----------------------------------------------------"

# 3. BUSCAR EL ÚLTIMO RESPALDO
ULTIMO_BACKUP=$(ls -t "$RUTA_RESPALDOS"/*.tar.gz 2>/dev/null | head -n 1)

if [ -z "$ULTIMO_BACKUP" ]; then
    echo "❌ Error: No se encontraron archivos de respaldo en $RUTA_RESPALDOS"
    exit 1
fi

echo "📦 Archivo encontrado: $(basename "$ULTIMO_BACKUP")"
echo "⚠️  ADVERTENCIA: Esto borrará los cambios actuales en el Kingston."
echo ""
read -p "¿Estás seguro de que quieres sobreescribir Synaptik? (s/n): " CONFIRMACION

if [[ "$CONFIRMACION" != "s" && "$CONFIRMACION" != "S" ]]; then
    echo "🛑 Restauración cancelada. No se tocó nada."
    exit 0
fi

# 4. EJECUTAR RESTAURACIÓN
echo "⏳ Extrayendo archivos en $RUTA_DESTINO..."

# -x (extraer), -z (descomprimir gzip), -f (archivo), -C (donde soltarlo)
if tar -xzf "$ULTIMO_BACKUP" -C "$RUTA_DESTINO"; then
    echo "✅ ¡Éxito! Synaptik ha sido restaurado a su estado anterior."
    
    # 5. AJUSTAR DUEÑO (Nuevamente, devolvemos el Kingston a luxce2)
    chown -R luxce2:luxce2 "$RUTA_DESTINO/synaptik-lite"
    echo "👤 Permisos de usuario restaurados en el Kingston."
else
    echo "❌ Error crítico durante la restauración."
    exit 1
fi

echo "----------------------------------------------------"
echo "🏁 Proceso finalizado. ¡Vuelve al código!"