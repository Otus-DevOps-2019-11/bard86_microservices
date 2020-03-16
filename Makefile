.DEFAULT_GOAL := info

USER_NAME ?= dbarsukov
export USER_NAME

info:
	@echo Build reddit app and infra docker images and push it to Dockerhub. Login before push.

all: build push run

run: run-app run-monitring

run-monitring:
	cd docker && docker-compose -f docker-compose-monitoring.yml up -d

run-app:
	cd docker && docker-compose up -d

stop: stop-app stop-monitoring

stop-app:
	cd docker && docker-compose down

stop-monitoring:
	cd docker && docker-compose -f docker-compose-monitoring.yml down

build: ui comment post prometheus cloudprober alertmanager telegraf

ui:
	cd src/ui && bash docker_build.sh

comment:
	cd src/comment && bash docker_build.sh

post:
	cd src/post-py && bash docker_build.sh

prometheus:
	cd monitoring/prometheus && docker build -t ${USER_NAME}/prometheus .

cloudprober:
	cd monitoring/cloudprober && docker build -t ${USER_NAME}/cloudprober .

alertmanager:
	cd monitoring/alertmanager && docker build -t ${USER_NAME}/alertmanager .

telegraf:
	cd monitoring/telegraf && docker build -t ${USER_NAME}/telegraf .

push: ui-push comment-push post-push prometheus-push cloudprober-push alertmanager-push telegraf-push

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

telegraf-push:
	docker push ${USER_NAME}/telegraf:latest

