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
        echo "Opción inválida. Escribe 'uefi' o 'bios'."
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

# Pedir la partición EFI solo si el sistema usa UEFI
if [[ "$BOOT_MODE" == "uefi" ]]; then
    echo "Discos disponibles:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    
    # Preguntar si existe una partición previa para evitar duplicados y problemas
    while true; do
        read -p "¿Deseas reutilizar una partición EFI existente? (si/no): " USE_EXISTING_EFI
        case "$USE_EXISTING_EFI" in
            si)
                # Solicitar la partición existente
                while true; do
                    read -p "Ingresa la partición EFI existente (ej. sda1, nvme0n1p1): " EFI_PART
                    
                    # Validar que exista la partición
                    if [ -b "/dev/$EFI_PART" ]; then
                        EFI_PARTITION="/dev/$EFI_PART"
                        echo "Usando partición EFI existente: $EFI_PARTITION"
                        break
                    else
                        echo "Partición inválida. Intenta de nuevo."
                    fi
                done
                break
                ;;
            no)
                # Solicitar la nueva partición
                while true; do
                    read -p "Ingresa la partición EFI (ej. sda1, nvme0n1p1): " EFI_PART
                    
                    # Validar que exista la partición
                    if [ -b "/dev/$EFI_PART" ]; then
                        EFI_PARTITION="/dev/$EFI_PART"
                        echo "Partición EFI seleccionada: $EFI_PARTITION"
                        break
                    else
                        echo "Partición inválida. Intenta de nuevo."
                    fi
                done
                ;;
            *)
                echo "Respuesta inválida. Escribe 'si' o 'no'."
                ;;
        esac
    done
fi

# Confirmar si desea formatear la partición raíz
read -p "¿Deseas formatear la partición raíz $ROOT_PARTITION? (si/no): " FORMAT_ROOT

if [[ "$FORMAT_ROOT" == "si" ]]; then
    mkfs.ext4 "$ROOT_PARTITION"
    echo "Partición raíz formateada."
else
    echo "No se formateará la raíz. Asegúrate de que esté vacía o correctamente configurada."
fi

# Montar la partición raíz
mount "$ROOT_PARTITION" /mnt

# Crear carpeta y montar EFI si es necesario
if [[ "$BOOT_MODE" == "uefi" ]]; then
    mkdir -p /mnt/boot/efi
    mount "$EFI_PARTITION" /mnt/boot/efi
fi

# Sistema base
echo "Instalando paquetes base en el nuevo sistema..."

# Validar que el archivo de paquetes exista
if [ ! -f "$(dirname "$0")/packages.txt" ]; then
    echo "No se encontró packages.txt en el mismo directorio del script."
    exit 1
fi

# Ejecutar pacstrap con la lista de paquetes
pacstrap -K /mnt $(< "$(dirname "$0")/packages.txt")
echo "Paquetes instalados correctamente."

echo "Generando archivo fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
echo "fstab generado correctamente."

# Guardamos las variables para pasarlas como variables de entorno
echo "export USERNAME=$USERNAME" >> /mnt/root/.chrootenv
echo "export DISK=$DISK" >> /mnt/root/.chrootenv
echo "export BOOT_MODE=$BOOT_MODE" >> /mnt/root/.chrootenv

# Entrar al nuevo sistema
echo "Entrando al sistema con arch-chroot..."
cp "$0" /mnt/install.sh
arch-chroot /mnt /bin/bash /install.sh --post-install

if [[ "$1" == "--post-install" ]]; then
    # Cargamos las variables de entorno
    source /root/.chrootenv

    echo "Configurando el sistema dentro de chroot..."

    echo "$HOSTNAME" > /etc/hostname

    ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
    hwclock --systohc

    echo "Configurando locales..."
    sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    sed -i 's/^#es_CO.UTF-8/es_CO.UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=es_CO.UTF-8" > /etc/locale.conf

    echo "Estableciendo contraseña para root..."
    passwd

    echo "Creando usuario $USERNAME..."
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Estableciendo contraseña para $USERNAME..."
    passwd "$USERNAME"

    echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

    echo "Instalando GRUB..."

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    else
        grub-install --target=i386-pc "$DISK"
    fi

    grub-mkconfig -o /boot/grub/grub.cfg

    echo "Eliminando instalador temporal..."
    rm /install.sh

    echo "Eliminando el archivo temporal (variables de entorno)"
    rm -f /root/.chrootenv

    echo "¡Instalación básica completada! Puedes salir del chroot y reiniciar."
    exit 0
fi

