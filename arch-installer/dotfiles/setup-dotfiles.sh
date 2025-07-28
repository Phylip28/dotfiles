#!/bin/bash

# Validacion de ejecucion (no ejecutar como sudo)
if [[ "$EUID" -eq 0 ]]; then
    echo -e "No ejecutes este script como root ni con sudo."
    echo "Hazlo desde tu usuario normal para que los archivos se copien a tu home correctamente."
    exit 1
fi

# Variables
CONFIG_DIR="$HOME/.config"
BIN_DIR="$HOME/.local/bin"
REPO_DIR="$(pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%s)"

echo "Instalando dotfiles..."

# Validar de ruta
if [[ ! -d "$REPO_DIR/config" || ! -d "$REPO_DIR/scripts" ]]; then
    echo "Por favor ejecuta el script desde la raiz del repositorio"
    exit 1
fi

# Preguntar por backup
read -p "¿Deseas hacer un respaldo de tus archivos actuales? (s/n): " make_backup

# Validar entrada
make_backup=$(echo "$make_backup" | tr '[:upper:]' '[:lower:]')

# Condicion
if [[ "$make_backup" == "s" ]]; then
    BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%s)"
    echo "Creando respaldo en $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$CONFIG_DIR" "$BACKUP_DIR/config"
    cp -r "$BIN_DIR" "$BACKUP_DIR/bin"
    echo "Respaldo creado exitosamente ✅"
fi

# Crear directorios si no existen
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# Copiar archivos de configuracion
echo "Copiando configuraciones..."
cp -r "$REPO_DIR/config/." "$CONFIG_DIR"

# Copiar scripts
echo "Copiando scripts..."
cp -r "$REPO_DIR/scripts/." "$BIN_DIR"
chmod +x "$BIN_DIR"/* # Otorgar permisos de ejecucion

# Salida
echo "Dotfiles instalados correctamente ✅"
