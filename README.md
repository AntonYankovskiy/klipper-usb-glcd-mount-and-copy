# Klipper USB Auto-mount for GLCD
Automatically mount USB drives and copy G-code files for 3D printers on Klipper with GLCD.

Автоматическое монтирование USB-флешек для 3D-принтеров с Klipper и графическим LCD.

Подключите USB-флешку - файлы автоматически появятся в папке printer_data/gcodes/ с префиксом устройства.

## Функции
- Автоматическое монтирование при подключении USB
- Копирование новых .gcode файлов с префиксом устройства
- Обработка извлеченных без размонтирования устройст
- Поддержка нескольких USB-флешек

## Установка
```bash
git clone https://github.com/AntonYankovskiy/klipper-usb-glcd-mount-and-copy
cd klipper-usb-glcd-mount-and-copy
sudo make install
```

## Удаление
```bash
cd klipper-usb-glcd-mount-and-copy
sudo make uninstall
```
