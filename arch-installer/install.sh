#!/bin/bash

# Variables
DISK="/dev/sda"
HOSTNAME="arch"
read -p "Enter the new username: " USERNAME

# Password validation (maximum 3 attempts)
MAX_ATTEMPTS=3
attempt=1

while [ $attempt -le $MAX_ATTEMPTS ]; do
    read -s -p "Enter password for $USERNAME: " PASSWORD
    echo
    read -s -p "Confirm password: " PASSWORD_CONFIRM
    echo

    # Validate if passwords match
    if [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]]; then
        echo "Password confirmed correctly."
        break
    else
        echo "Passwords don't match. Attempt $attempt of $MAX_ATTEMPTS."
        ((attempt++))
    fi
done

# If it fails 3 times, exit script
if [ $attempt -gt $MAX_ATTEMPTS ]; then
    echo "Maximum attempts exceeded. Aborting installation..."
    exit 1
fi

# Boot mode
while true; do
    read -p "Are you using UEFI or BIOS? (uefi/bios): " BOOT_MODE
    
    # Validate input    
    if [[ "$BOOT_MODE" == "uefi" || "$BOOT_MODE" == "bios" ]]; then
        echo "Selected mode: $BOOT_MODE"
        break
    else
        echo "Invalid option. Type 'uefi' or 'bios'."
    fi
done

# Show available partitions 
echo "Available disks and partitions"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Ask for root partition 
while true; do
    read -p "Enter the partition where you'll install Arch (e.g. sda3, nvme0n1p2): " PARTITION
    
    # Verify if partition really exists
    if [ -b "/dev/$PARTITION" ]; then
        ROOT_PARTITION="/dev/$PARTITION"
        echo "Selected partition: $ROOT_PARTITION"
        break
    else
        echo "Invalid partition. Try again."
    fi
done

# Ask for EFI partition only if system uses UEFI
if [[ "$BOOT_MODE" == "uefi" ]]; then
    echo "Available disks:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    
    # Ask if an existing partition exists to avoid duplicates and problems
    while true; do
        read -p "Do you want to reuse an existing EFI partition? (yes/no): " USE_EXISTING_EFI
        case "$USE_EXISTING_EFI" in
            yes)
                # Request existing partition
                while true; do
                    read -p "Enter the existing EFI partition (e.g. sda1, nvme0n1p1): " EFI_PART
                    
                    # Validate partition exists
                    if [ -b "/dev/$EFI_PART" ]; then
                        EFI_PARTITION="/dev/$EFI_PART"
                        echo "Using existing EFI partition: $EFI_PARTITION"
                        break
                    else
                        echo "Invalid partition. Try again."
                    fi
                done
                break
                ;;
            no)
                # Request new partition
                while true; do
                    read -p "Enter the EFI partition (e.g. sda1, nvme0n1p1): " EFI_PART
                    
                    # Validate partition exists
                    if [ -b "/dev/$EFI_PART" ]; then
                        EFI_PARTITION="/dev/$EFI_PART"
                        echo "Selected EFI partition: $EFI_PARTITION"
                        break
                    else
                        echo "Invalid partition. Try again."
                    fi
                done
                ;;
            *)
                echo "Invalid response. Type 'yes' or 'no'."
                ;;
        esac
    done
fi

# Confirm if you want to format root partition
read -p "Do you want to format the root partition $ROOT_PARTITION? (yes/no): " FORMAT_ROOT

if [[ "$FORMAT_ROOT" == "yes" ]]; then
    mkfs.ext4 "$ROOT_PARTITION"
    echo "Root partition formatted."
else
    echo "Root won't be formatted. Make sure it's empty or properly configured."
fi

# Mount root partition
mount "$ROOT_PARTITION" /mnt

# Create folder and mount EFI if necessary
if [[ "$BOOT_MODE" == "uefi" ]]; then
    mkdir -p /mnt/boot/efi
    mount "$EFI_PARTITION" /mnt/boot/efi
fi

# Base system
echo "Installing base packages on the new system..."

# Validate that packages file exists
if [ ! -f "$(dirname "$0")/packages.txt" ]; then
    echo "packages.txt not found in the same directory as the script."
    exit 1
fi

# Execute pacstrap with package list
pacstrap -K /mnt $(< "$(dirname "$0")/packages.txt")
echo "Packages installed correctly."

echo "Generating fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab
echo "fstab generated correctly."

# Save variables to pass as environment variables
echo "export USERNAME=$USERNAME" >> /mnt/root/.chrootenv
echo "export DISK=$DISK" >> /mnt/root/.chrootenv
echo "export BOOT_MODE=$BOOT_MODE" >> /mnt/root/.chrootenv

# Enter new system
echo "Entering system with arch-chroot..."
cp "$0" /mnt/install.sh
arch-chroot /mnt /bin/bash /install.sh --post-install

if [[ "$1" == "--post-install" ]]; then
    # Load environment variables
    source /root/.chrootenv

    echo "Configuring system inside chroot..."

    echo "$HOSTNAME" > /etc/hostname

    ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
    hwclock --systohc

    echo "Configuring locales..."
    sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    sed -i 's/^#es_CO.UTF-8/es_CO.UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=es_CO.UTF-8" > /etc/locale.conf

    echo "Setting root password..."
    passwd

    echo "Creating user $USERNAME..."
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Setting password for $USERNAME..."
    passwd "$USERNAME"

    echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

    echo "Installing GRUB..."

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    else
        grub-install --target=i386-pc "$DISK"
    fi

    grub-mkconfig -o /boot/grub/grub.cfg

    echo "Removing temporary installer..."
    rm /install.sh

    echo "Removing temporary file (environment variables)"
    rm -f /root/.chrootenv

    echo "Basic installation completed! You can exit chroot and reboot."
    exit 0
fi

