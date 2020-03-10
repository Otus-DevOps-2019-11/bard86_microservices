.DEFAULT_GOAL := info

USERNAME ?= dbarsukov

info:
	@echo Build reddit app and infra docker images and push it to Dockerhub. Login before push.

all: build push

build: ui comment post prometheus cloudprober

ui:
	cd src/ui && docker build -t ${USERNAME}/ui .

comment:
	cd src/comment && docker build -t ${USERNAME}/comment .

post:
	cd src/post-py && docker build -t ${USERNAME}/post .

prometheus:
	cd monitoring/prometheus && docker build -t ${USERNAME}/prometheus .

cloudprober:
	cd monitoring/cloudprober && docker build -t ${USERNAME}/cloudprober .

push: ui-push comment-push post-push prometheus-push cloudprober-push

ui-push:
	docker push ${USERNAME}/ui:latest

comment-push:
	docker push ${USERNAME}/comment:latest

post-push:
	docker push ${USERNAME}/post:latest

prometheus-push:
	docker push ${USERNAME}/ui:latest

cloudprober-push:
	docker push ${USERNAME}/cloudprober:latest
