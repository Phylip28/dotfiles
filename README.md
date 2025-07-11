# Phylip dotfiles

Este repositorio contiene los archivos de configuración personalizados de mi sistema Arch Linux, instalado completamente desde cero, sin usar archinstall, asistentes de instalación o cualquier script de automatización.

![Vista previa](preview/feh.gif)

## Proposito y Tecnologias

Los dotfiles estan diseñados para crear un etorno minimalista, que sea eficiente y visualmente agradable.

- `i3` como gestor de ventanas
- `Alacritty` como emulador de terminal
- `Picom` para crear efectos y modificaciones visuales
- `Fastfetch` para mostrar la información del sistema
- `Dunst` para manejar las notificaciones
- `Polybar` como barra de estado personalizable
- `Rofi` Como launcher para las aplicaciones
- `Flameshot` para capturas de pantalla
- `Feh` Para el fondo de escritorio

## Instalación

1. Clona o descarga el contenido del repositorio
2. Copia el contenido del directorio config a tu carpeta de configuracion local:
    ```bash
    cp -r config/* ~/.config/
    ```
3. Copia los scripts al directorio `~/.local/bin`:
    ```bash
    cp -r scripts/* ~/.local/bin/
    ```
4. Ejecuta el siguiente comando:

    ```bash
    find ~/.local/bin/ -type f -name "*.sh" -exec chmod +x {} \;
    ```

## Sugerencias

Puedes hacer forks o sugerir mejoras para optimizar el sistema, estoy abierto a nuevas ideas o modificaciones.

## Importante

Por el momento puedes clonar y mover las carpetas a sus repectivos lugares, pero dentro de poco creare un script para automatizar el proceso.
