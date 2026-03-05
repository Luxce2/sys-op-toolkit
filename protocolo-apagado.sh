#!/bin/bash

# ==============================================================================
# NOMBRE: protocolo-apagado.sh (V2.0 BLINDADA)
# PROPÓSITO: Cierre seguro de contenedores Docker, procesos de IA, liberación 
#            de GPU (NVIDIA), cierre de sesiones en segundo plano, 
#            VERIFICACIÓN DE DESMONTAJE y prevención de corrupción de datos.
# ==============================================================================

ARCHIVO_LOG="$HOME/historial_apagado.log"
PUNTO_MONTAJE="/mnt/Kingston"

# ------------------------------------------------------------------------------
# FUNCIÓN: registrar_log
# ------------------------------------------------------------------------------
registrar_log() {
    FECHA_HORA=$(date +'%Y-%m-%d %H:%M:%S')
    MENSAJE="[$FECHA_HORA] $1"
    echo "$MENSAJE"
    echo "$MENSAJE" >> "$ARCHIVO_LOG"
}

# ==============================================================================
# INICIO DEL PROTOCOLO
# ==============================================================================

registrar_log "----------------------------------------------------"
registrar_log "🔴 INICIANDO PROTOCOLO DE APAGADO SEGURO V2.0"

# 1. GESTIÓN DE DOCKER (CONTENEDORES Y MOTOR)
if [ -x "$(command -v docker)" ]; then
    CONTENEDORES_ACTIVOS=$(docker ps -q)
    
    if [ ! -z "$CONTENEDORES_ACTIVOS" ]; then
        registrar_log "🐳 Deteniendo contenedores de Docker activos..."
        docker stop $CONTENEDORES_ACTIVOS > /dev/null
        registrar_log "✅ Contenedores de Docker detenidos con éxito."
    else
        registrar_log "ℹ️ Docker: No hay contenedores activos."
    fi
    
    # [NUEVO BLINDAJE]: Apagamos el motor para destruir los túneles al disco
    registrar_log "🛑 Apagando el motor de Docker (dockerd)..."
    sudo systemctl stop docker.socket docker.service
    registrar_log "✅ Motor de Docker apagado. Vínculos liberados."
fi

# 2. GESTIÓN DE PROCESOS DE IA Y DESARROLLO
registrar_log "🤖 Buscando procesos de IA (Ollama, Python, etc.)..."
PROCESOS=("ollama" "python" "python3" "jupyter" "llama-edge" "node")

for proc in "${PROCESOS[@]}"; do
    if pgrep -x "$proc" > /dev/null; then
        registrar_log "⚠️  Cerrando proceso detectado: $proc"
        sudo pkill -15 "$proc"
    fi
done

# 3. GESTIÓN DE GPU (NVIDIA)
if [ -x "$(command -v nvidia-smi)" ]; then
    registrar_log "🎮 Verificando estado de la VRAM de la GPU NVIDIA..."
    GPU_PROCS=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader)
    
    if [ ! -z "$GPU_PROCS" ]; then
        registrar_log "⚠️  Se encontraron procesos en la GPU. Limpiando VRAM..."
        for pid in $GPU_PROCS; do
            sudo kill -15 $pid
        done
        sleep 2
        registrar_log "✅ VRAM de la GPU liberada."
    else
        registrar_log "✅ GPU: Libre de procesos atascados."
    fi
fi

# 4. GESTIÓN DE SESIONES DE TERMINAL (Tmux / Screen)
if pgrep -x "tmux" > /dev/null; then
    registrar_log "🖥️  Cerrando sesiones activas de Tmux..."
    tmux kill-server
fi
if pgrep -x "screen" > /dev/null; then
    registrar_log "🖥️  Cerrando sesiones activas de Screen..."
    pkill -15 "screen"
fi

# 5. SINCRONIZACIÓN DE DISCO
registrar_log "💾 Sincronizando datos con el disco duro físico..."
sync
sleep 2

# ==============================================================================
# 6. [NUEVO BLINDAJE] DESMONTAJE VERIFICADO DEL NVMe
# ==============================================================================
registrar_log "⚓ Intentando desmontar $PUNTO_MONTAJE de forma segura..."

# Intentamos desmontar (desenganchar) el disco
sudo umount "$PUNTO_MONTAJE" 2>/dev/null

# Verificamos si sigue montado a pesar del comando anterior
if mountpoint -q "$PUNTO_MONTAJE"; then
    registrar_log "❌ ALERTA ROJA: El disco NO se pudo desmontar."
    registrar_log "⚠️ Algún proceso sigue usando el disco. Apagado CANCELADO."
    
    # Listamos quién está ocupando el disco
    registrar_log "🔍 Procesos bloqueando el disco:"
    sudo lsof +D "$PUNTO_MONTAJE" | tee -a "$ARCHIVO_LOG"
    
    echo "----------------------------------------------------"
    echo "🛑 CIERRE ABORTADO PARA PROTEGER TUS DATOS 🛑"
    echo "Revisa qué programa de la lista anterior está usando el disco."
    exit 1
else
    registrar_log "✅ Disco $PUNTO_MONTAJE desmontado con éxito. Cero puentes activos."
fi

# ==============================================================================
# 7. APAGADO FINAL
# ==============================================================================
registrar_log "🏁 Protocolo finalizado con éxito. El sistema es seguro, puedes apagar la máquina."
registrar_log "----------------------------------------------------"

# sudo poweroff