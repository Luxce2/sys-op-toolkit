# 🛠️ Sys-Op Toolkit

Bienvenido a mi arsenal personal de scripts y automatizaciones. Este repositorio (`sys-op-toolkit`) contiene herramientas diseñadas para optimizar el desarrollo, administrar servidores locales y mantener el sistema operativo funcionando de manera segura y eficiente.

---

## 📜 Scripts Disponibles

### 🛑 Protocolo de Apagado Seguro (`protocolo-apagado.sh`)
Un "botón de pánico" o script de cierre seguro diseñado para evitar la corrupción de datos antes de apagar el equipo. 

**¿Qué hace?**
1. Detiene todos los contenedores de **Docker** de forma segura.
2. Cierra procesos de **IA y Python** (Ollama, Jupyter, Llama-edge, etc.).
3. Libera la VRAM cerrando procesos atascados en la **GPU (NVIDIA)**.
4. Cierra sesiones en segundo plano de **Tmux** y **Screen**.
5. Obliga a sincronizar la memoria RAM con el disco duro (`sync`).
6. Guarda un registro de todo lo cerrado en `~/historial_apagado.log`.

**⚙️ Instalación y Uso**
Para poder ejecutar este comando desde cualquier parte de tu terminal, te recomiendo crear un enlace simbólico (symlink) a tu carpeta de binarios:

```bash
# 1. Dale permisos de ejecución
chmod +x protocolo-apagado.sh

# 2. Crea el enlace global (opcional)
sudo ln -s ~/mis-scripts-personales/protocolo-apagado.sh /usr/local/bin/protocolo-apagado

Para usarlo, simplemente ejecuta en tu terminal:

Bash protocolo-apagado

Repositorio mantenido por Luxce2.
