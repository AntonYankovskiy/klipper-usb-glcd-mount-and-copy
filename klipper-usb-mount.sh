#!/bin/bash

USER_NAME=$(id -nu 1000 2>/dev/null || echo "pi")
BASE_DIR="/home/$USER_NAME/printer_data/gcodes"
DEVICE_NAME="${1##*/}"
[ -z "$DEVICE_NAME" ] && exit 1

MOUNT_DIR="$BASE_DIR/$DEVICE_NAME"
DEVICE_PATH="/dev/$DEVICE_NAME"

if mountpoint -q "$MOUNT_DIR" && ! [ -b "$DEVICE_PATH" ]; then
    umount -lf "$MOUNT_DIR" 2>/dev/null
    [ -d "$MOUNT_DIR" ] && rmdir "$MOUNT_DIR" 2>/dev/null
    rm -f "$BASE_DIR/${DEVICE_NAME}_"*.gcode 2>/dev/null
fi

if ! [ -b "$DEVICE_PATH" ]; then
    mountpoint -q "$MOUNT_DIR" && umount "$MOUNT_DIR"
    [ -d "$MOUNT_DIR" ] && rmdir "$MOUNT_DIR" 2>/dev/null
    rm -f "$BASE_DIR/${DEVICE_NAME}_"*.gcode 2>/dev/null
    exit 0
fi

mkdir -p "$MOUNT_DIR"
mount -t auto -o "noatime,nodiratime,uid=1000,gid=1000" "$DEVICE_PATH" "$MOUNT_DIR" 2>/dev/null || {
    rmdir "$MOUNT_DIR" 2>/dev/null
    exit 1
}

# ---- УМНОЕ КОПИРОВАНИЕ: только новых файлов ----
COPIED_COUNT=0

find "$MOUNT_DIR" -name "*.gcode" -type f | while read -r usb_file; do
    # Получаем базовое имя файла (без пути)
    base_name=$(basename "$usb_file")
    
    # Имя для копии с префиксом устройства
    target_name="${DEVICE_NAME}_${base_name}"
    target_path="$BASE_DIR/$target_name"
    
    # Проверяем, нужно ли копировать
    NEED_COPY=true
    
    if [ -f "$target_path" ]; then
        # Сравниваем размер и дату модификации
        usb_size=$(stat -c %s "$usb_file" 2>/dev/null)
        usb_mtime=$(stat -c %Y "$usb_file" 2>/dev/null)
        target_size=$(stat -c %s "$target_path" 2>/dev/null 2>/dev/null || echo 0)
        target_mtime=$(stat -c %Y "$target_path" 2>/dev/null 2>/dev/null || echo 0)
        
        # Если размер И дата совпадают - файл уже скопирован
        if [ "$usb_size" = "$target_size" ] && [ "$usb_mtime" = "$target_mtime" ]; then
            NEED_COPY=false
        fi
    fi
    
    # Копируем если нужно
    if [ "$NEED_COPY" = true ]; then
        if cp -n "$usb_file" "$target_path" 2>/dev/null; then
            # Сохраняем оригинальную дату модификации
            touch -r "$usb_file" "$target_path" 2>/dev/null
            COPIED_COUNT=$((COPIED_COUNT + 1))
        fi
    fi
done

exit 0