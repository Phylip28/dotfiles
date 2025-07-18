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

1. Clona o descarga el contenido del repositorio:
    ```bash
    git clone https://github.com/Phylip28/dotfiles.git
    ```
    o con SSH
    ```bash
    git clone git@github.com:Phylip28/dotfiles.git
    ```
2. Entra al directorio:
    ```bash
    cd dotfiles
    ```
3. Da permisos de ejecución al script de instalación:
    ```bash
    chmod +x setup-dotfiles.sh
    ```
4. Ejecuta el script:

    ```bash
    ./setup-dotfiles.sh
    ```

>**Nota:** El script te preguntará si deseas hacer un respaldo de tus configuraciones actuales. No necesitas hacerlo manualmente. 

## Sugerencias

Puedes hacer forks o sugerir mejoras para optimizar el sistema, estoy abierto a nuevas ideas o modificaciones.