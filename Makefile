.DEFAULT_GOAL := info

USER_NAME ?= dbarsukov

info:
	@echo Build reddit app and infra docker images and push it to Dockerhub. Login before push.

all: build push

build: ui comment post prometheus cloudprober alertmanager

ui:
	cd src/ui && docker_build.sh

comment:
	cd src/comment && docker_build.sh

post:
	cd src/post-py && docker_build.sh

prometheus:
	cd monitoring/prometheus && docker build -t ${USER_NAME}/prometheus .

cloudprober:
	cd monitoring/cloudprober && docker build -t ${USER_NAME}/cloudprober .

alertmanager:
	cd monitoring/alertmanager && docker build -t ${USER_NAME}/alertmanager .

push: ui-push comment-push post-push prometheus-push cloudprober-push alertmanager-push

ui-push:
	docker push ${USER_NAME}/ui:latest

comment-push:
	docker push ${USER_NAME}/comment:latest

post-push:
	docker push ${USER_NAME}/post:latest

prometheus-push:
	docker push ${USER_NAME}/ui:latest

cloudprober-push:
	docker push ${USER_NAME}/cloudprober:latest

alertmanager-push:
	docker push ${USER_NAME}/alertmanager:latest
