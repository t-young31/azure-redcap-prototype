SHELL:=/bin/bash

login:
	az login

deploy:
	source load_env.sh && \
	cd terraform && \
	terraform init -upgrade && \
	terraform validate && \
	terraform apply

destroy:
	source load_env.sh && \
	cd terraform && \
	terraform apply -destroy

fmt:
	terraform fmt --recursive
