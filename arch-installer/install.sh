#!/bin/bash

# Variables
DISK="/dev/sda"
HOSTNAME="arch"
read -p "Ingresa el nombre del nuevo usuario: " USERNAME

# Validación de contraseña (maximo 3 intentos)
MAX_ATTEMPTS=3
attempt=1

while [ $attempt -le $MAX_ATTEMPTS ]; do
    read -s -p "Ingresa la contraseña para $USERNAME: " PASSWORD
    echo
    read -s -p "Confirma la contraseña: " PASSWORD_CONFIRM
    echo

    # Validar si las contraseñas coinciden
    if [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]]; then
        echo "Contraseña confirmada correctamente."
        break
    else
        echo "Las contraseñas no coinciden. Intento $attempt de $MAX_ATTEMPTS."
        ((attempt++))
    fi
done

# Si falla 3 veces, salir del script
if [ $attempt -gt $MAX_ATTEMPTS ]; then
    echo "Se excedieron los intentos permitidos. Abortando instalación..."
    exit 1
fi

# Modo de arranque
while true; do
    read -p "¿Estás usando UEFI o BIOS? (uefi/bios): " BOOT_MODE
    
    # Validar la entrada    
    if [[ "$BOOT_MODE" == "uefi" || "$BOOT_MODE" == "bios" ]]; then
        echo "Modo seleccionado: $BOOT_MODE"
        break
    else
        echo "❗ Opción inválida. Escribe 'uefi' o 'bios'."
    fi
done

# Mostrar las particiones disponibles 
echo "Discos y particiones disponibles"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Pedir la partición raíz 
while true; do
    read -p "Ingresa la partición donde vas a instalar Arch (ej. sda3, nvme0n1p2): " PARTITION
    
    # Verificar si realmente existe la partición
    if [ -b "/dev/$PARTITION" ]; then
        ROOT_PARTITION="/dev/$PARTITION"
        echo "Partición seleccionada: $ROOT_PARTITION"
        break
    else
        echo "Partición inválida. Intenta de nuevo."
    fi
done


