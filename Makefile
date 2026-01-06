# Фиксированные пути установки
BIN_DIR = /usr/local/bin
UDEV_DIR = /lib/udev/rules.d
SCRIPT_NAME = klipper-usb-mount
UDEV_RULE = 99-klipper-usb.rules

# Исходные файлы
SCRIPT_SRC = klipper-usb-mount.sh
RULE_SRC = klipper-usb.rules

.PHONY: all install uninstall clean reload check help

all: install

# Установка
install: $(SCRIPT_SRC) $(RULE_SRC)
	@echo "Установка Klipper USB Auto-mount..."
	
	# Установка скрипта
	install -m 0755 $(SCRIPT_SRC) $(BIN_DIR)/$(SCRIPT_NAME)
	@echo "Скрипт установлен: $(BIN_DIR)/$(SCRIPT_NAME)"
	
	# Установка правила udev
	install -m 0644 $(RULE_SRC) $(UDEV_DIR)/$(UDEV_RULE)
	@echo "Правило udev установлено: $(UDEV_DIR)/$(UDEV_RULE)"
	
	# Перезагрузка правил udev
	@echo "Перезагрузка правил udev..."
	@if udevadm control --reload-rules 2>/dev/null && udevadm trigger 2>/dev/null; then \
		echo "Правила udev активированы"; \
	else \
		echo "Внимание: не удалось перезагрузить правила udev"; \
	fi
	
	@echo "Установка завершена!"

# Удаление
uninstall:
	@echo "Удаление Klipper USB Auto-mount..."
	
	# Удаление скрипта
	@if [ -f "$(BIN_DIR)/$(SCRIPT_NAME)" ]; then \
		rm -f "$(BIN_DIR)/$(SCRIPT_NAME)"; \
		echo "Скрипт удален: $(BIN_DIR)/$(SCRIPT_NAME)"; \
	else \
		echo "Скрипт не найден: $(BIN_DIR)/$(SCRIPT_NAME)"; \
	fi
	
	# Удаление правила udev
	@if [ -f "$(UDEV_DIR)/$(UDEV_RULE)" ]; then \
		rm -f "$(UDEV_DIR)/$(UDEV_RULE)"; \
		echo "Правило udev удалено: $(UDEV_DIR)/$(UDEV_RULE)"; \
	else \
		echo "Правило udev не найдено: $(UDEV_DIR)/$(UDEV_RULE)"; \
	fi
	
	# Перезагрузка правил udev
	@echo "Перезагрузка правил udev..."
	@if udevadm control --reload-rules 2>/dev/null; then \
		echo "Правила udev обновлены"; \
	else \
		echo "Внимание: не удалось перезагрузить правила udev"; \
	fi
	
	@echo "Удаление завершено!"