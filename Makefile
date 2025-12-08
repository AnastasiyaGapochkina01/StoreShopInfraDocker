ifneq (,$(wildcard ./.env))
    include .env
    export
endif

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

build:
	docker compose build --no-cache

logs:
	docker compose logs -f

shell-php:
	docker compose exec php-fpm bash

shell-db:
	docker compose exec db mysql -u ${MARIADB_USER} -p${MARIADB_PASSWORD} ${MARIADB_DATABASE}

install:
	@echo "Установка Magento 2..."
	docker compose exec php-fpm composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition .

setup:
	@echo "Настройка Magento 2..."
	docker compose exec php-fpm php bin/magento setup:install \
		--base-url=http://${MAGENTO_URL} \
		--db-host=${DB_HOST} \
		--db-name=${MARIADB_DATABASE} \
		--db-user=${MARIADB_USER} \
		--db-password=${MARIADB_PASSWORD} \
		--admin-firstname=Admin \
		--admin-lastname=Admin \
		--admin-email=${MAGENTO_ADMIN_EMAIL} \
		--admin-user=${MAGENTO_ADMIN_USER} \
		--admin-password=${MAGENTO_ADMIN_PASSWORD} \
		--language=${MAGENTO_LANGUAGE} \
		--currency=${MAGENTO_CURRENCY} \
		--timezone=${MAGENTO_TIMEZONE} \
		--opensearch-host=${SEARCH_HOST} \
		--use-rewrites=1
	@echo "Отключение двухфакторной аутентификации..."
	docker compose exec php-fpm php bin/magento module:disable \
		Magento_TwoFactorAuth \
		Magento_AdminAdobeImsTwoFactorAuth
	@echo "Очистка кеша..."
	docker compose exec php-fpm php bin/magento cache:flush
clean:
	docker compose down -v
	sudo rm -rf app/*
	sudo find app -mindepth 1 -maxdepth 1 -type f -delete
