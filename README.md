# 🛠️ Sys-Op Toolkit

Bienvenido a mi arsenal personal de scripts y automatizaciones. Este repositorio (`sys-op-toolkit`) contiene herramientas diseñadas para optimizar el desarrollo, administrar servidores locales y mantener el sistema operativo funcionando de manera segura y eficiente.

---

## 📜 Scripts Disponibles

### 🛑 Protocolo de Apagado Seguro (`protocolo-apagado.sh`)
Un "botón de pánico" diseñado para evitar la corrupción de datos antes de apagar el equipo. 

**¿Qué hace?**
1. Detiene todos los contenedores de **Docker** de forma segura.
2. Cierra procesos de **IA y Python** (Ollama, Jupyter, Llama-edge, etc.).
3. Libera la VRAM cerrando procesos atascados en la **GPU (NVIDIA)**.
4. Cierra sesiones en segundo plano de **Tmux** y **Screen**.
5. Obliga a sincronizar la memoria RAM con el disco duro (`sync`).
6. Genera un log detallado en `~/historial_apagado.log`.

---

### 🛡️ Sistema de Rescate Synaptik (El "Ctrl+Z" de Emergencia)
Conjunto de herramientas para editar código en "caliente" sin miedo a romper la base de datos o el proyecto.

#### 1. `save-synaptik` (`backup-synaptik.sh`)
Crea un punto de restauración total (incluyendo archivos `.env` y datos de Postgres).
* **Origen:** Disco Kingston (`/media/luxce2/Kingston/synaptik-lite`)
* **Destino:** Disco Principal (`~/respaldos_synaptik`)
* **Retención:** Mantiene estrictamente los **2 respaldos más recientes** para optimizar espacio.

#### 2. `restore-synaptik` (`restore-synaptik.sh`)
Restaura el proyecto al último estado guardado en segundos.
* **Acción:** Detecta el backup más nuevo, pide confirmación y sobreescribe el Kingston.
* **Permisos:** Restaura automáticamente la propiedad de los archivos a tu usuario local.

---

## ⚙️ Instalación y Configuración Global

Para ejecutar estos scripts como comandos globales desde cualquier parte de la terminal, sigue estos pasos:

```bash
# 1. Dar permisos de ejecución a todos los scripts
chmod +x ~/mis-scripts-personales/*.sh

# 2. Crear los enlaces simbólicos (Comandos Globales)
sudo ln -s ~/mis-scripts-personales/protocolo-apagado.sh /usr/local/bin/protocolo-apagado
sudo ln -s ~/mis-scripts-personales/backup-synaptik.sh /usr/local/bin/save-synaptik
sudo ln -s ~/mis-scripts-personales/restore-synaptik.sh /usr/local/bin/restore-synaptik

🚀 Uso Rápido

    Para apagar todo seguro: protocolo-apagado

    Para guardar un punto de control: sudo save-synaptik

    Para volver atrás si algo explotó: sudo restore-synaptik

Repositorio mantenido con ❤️ por Luxce2.