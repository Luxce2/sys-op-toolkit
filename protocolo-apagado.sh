#!/bin/bash

# ==============================================================================
# NOMBRE: protocolo-apagado.sh
# PROPÓSITO: Cierre seguro de contenedores Docker, procesos de IA, liberación 
#            de GPU (NVIDIA), cierre de sesiones en segundo plano y 
#            sincronización de disco. Evita corrupción de datos.
# ==============================================================================

# Definimos dónde se guardará el archivo de registro (log)
# $HOME se refiere a tu carpeta de usuario (ej. /home/tu_usuario/)
ARCHIVO_LOG="$HOME/historial_apagado.log"

# ------------------------------------------------------------------------------
# FUNCIÓN: registrar_log
# DESCRIPCIÓN: Toma un mensaje de texto, le añade la fecha/hora actual,
#              lo muestra en la consola y lo guarda en el archivo log.
# ------------------------------------------------------------------------------
registrar_log() {
    # Obtenemos la fecha y hora en formato: YYYY-MM-DD HH:MM:SS
    FECHA_HORA=$(date +'%Y-%m-%d %H:%M:%S')
    
    # Construimos el mensaje final
    MENSAJE="[$FECHA_HORA] $1"
    
    # Mostramos el mensaje en la terminal
    echo "$MENSAJE"
    
    # Añadimos el mensaje al final del archivo de log (usando >>)
    echo "$MENSAJE" >> "$ARCHIVO_LOG"
}

# ==============================================================================
# INICIO DEL PROTOCOLO
# ==============================================================================

registrar_log "----------------------------------------------------"
registrar_log "🔴 INICIANDO PROTOCOLO DE APAGADO SEGURO"

# 1. GESTIÓN DE DOCKER
# Comprueba si el comando 'docker' existe en el sistema
if [ -x "$(command -v docker)" ]; then
    # Obtiene solo los IDs de los contenedores que están corriendo
    CONTENEDORES_ACTIVOS=$(docker ps -q)
    
    if [ ! -z "$CONTENEDORES_ACTIVOS" ]; then
        registrar_log "🐳 Deteniendo contenedores de Docker activos..."
        docker stop $CONTENEDORES_ACTIVOS > /dev/null
        registrar_log "✅ Contenedores de Docker detenidos con éxito."
    else
        registrar_log "ℹ️ Docker: No hay contenedores activos."
    fi
fi

# 2. GESTIÓN DE PROCESOS DE IA Y DESARROLLO
registrar_log "🤖 Buscando procesos de IA (Ollama, Python, etc.)..."
# Lista de nombres de procesos que queremos buscar y cerrar
PROCESOS=("ollama" "python" "python3" "jupyter" "llama-edge" "node")

# Recorremos la lista de procesos uno por uno
for proc in "${PROCESOS[@]}"; do
    # Verifica si el proceso exacto está corriendo de fondo
    if pgrep -x "$proc" > /dev/null; then
        registrar_log "⚠️  Cerrando proceso detectado: $proc"
        pkill -15 "$proc" # Envía señal de cierre limpio
    fi
done

# 3. GESTIÓN DE GPU (NVIDIA)
# Verifica si las herramientas de NVIDIA están instaladas
if [ -x "$(command -v nvidia-smi)" ]; then
    registrar_log "🎮 Verificando estado de la VRAM de la GPU NVIDIA..."
    # Obtiene los PIDs (IDs de proceso) que están usando la tarjeta gráfica
    GPU_PROCS=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader)
    
    if [ ! -z "$GPU_PROCS" ]; then
        registrar_log "⚠️  Se encontraron procesos en la GPU. Limpiando VRAM..."
        for pid in $GPU_PROCS; do
            kill -15 $pid # Cierra el proceso que ocupa la GPU
        done
        sleep 2 # Pausa de 2 segundos para dar tiempo al sistema
        registrar_log "✅ VRAM de la GPU liberada."
    else
        registrar_log "✅ GPU: Libre de procesos atascados."
    fi
fi

# 4. GESTIÓN DE SESIONES DE TERMINAL (Tmux / Screen)
# Cierra servidores de terminales que pudiesen estar corriendo entrenamientos
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
# Obliga a escribir los datos de la memoria RAM (caché) en el disco
sync
sleep 2

registrar_log "🏁 Protocolo finalizado con éxito. El sistema es seguro para apagar."
registrar_log "----------------------------------------------------"
