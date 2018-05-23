SERVICES := api_core service_core auth
LIBS := api_core service_core

define command
	$(if $(filter $(1),$(LIBS)),run --rm --no-deps,exec) $(1)
endef

up:
	docker-compose up

up-d:
	docker-compose up -d

stop:
	docker-compose stop

build:
	docker build ./lib/api_core -t lib/api-core:latest
	docker build ./lib/service_core -t lib/service-core:latest
	docker build ./lib/images/base_service -t lib/base-service:latest
	docker build ./lib/images/base_api -t lib/base-api:latest
	docker-compose build

test: clean unit-test lint

test-all:
	for service in $(SERVICES) ; do \
		make test t=$$service ; \
	done

coverage:
	for service in $(SERVICES) ; do \
		make codecov t=$$service ; \
	done

unit-test:
	docker-compose $(call command,$(t)) pytest

lint: flake isort

logs:
	docker-compose logs $(t)

flake:
	docker-compose $(call command,$(t)) flake8

isort:
	docker-compose $(call command,$(t)) isort --check --diff -tc -rc .

fix-imports:
	docker-compose $(call command,$(t)) isort -tc -rc .

sh:
	docker-compose $(call command,$(t)) sh

outdated:
	docker-compose $(call command,$(t)) pip3 list --outdated --format=columns

clean:
	$(info Cleaning directories)
	@docker-compose $(call command,$(t)) sh -c "find . -name "*.pyo" | xargs rm -rf"
	@docker-compose $(call command,$(t)) sh -c "find . -name "*.cache" | xargs rm -rf"
	@docker-compose $(call command,$(t)) sh -c "find . -name "*.mypy_cache" | xargs rm -rf"
	@docker-compose $(call command,$(t)) sh -c "find . -name "__pycache__" -type d | xargs rm -rf"
	@docker-compose $(call command,$(t)) sh -c "find . -name ".pytest_cache" -type d | xargs rm -rf"
	@docker-compose $(call command,$(t)) sh -c "rm -f .coverage && rm -rf coverage/"

codecov:
	docker-compose $(call command,$(t)) codecov
