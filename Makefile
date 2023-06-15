SHELL:=/bin/bash

login:
	az login

deploy: deploy-acr build-and-push-redcap-app
	. load_env.sh && cd terraform && \
	terraform apply

tf-init:
	. load_env.sh && cd terraform && \
	terraform init -upgrade && \
	terraform validate

deploy-acr: tf-init
	. load_env.sh && cd terraform && \
	terraform apply -target="azurerm_container_registry.redcap"

build-and-push-redcap-app:
	. load_env.sh && \
	./redcap_app/build_and_push.sh

deploy-no-deps:
	. load_env.sh && cd terraform && \
	terraform apply

destroy:
	. load_env.sh && \
	cd terraform && \
	terraform apply -destroy

fmt:
	terraform fmt --recursive
