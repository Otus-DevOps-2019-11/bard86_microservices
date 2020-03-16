# bard86_microservices
bard86 microservices repository

## Docker - 2

### set up docker repository
> for Ubuntu 19.10 use `disco` instead of $(lsb_release -cs)
```console
$ sudo apt-get update
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```
### install docker
```console
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```
### verify docker
```console
$ sudo docker version
$ sudo docker run hello-world
```
### after docker install steps
- https://docs.docker.com/install/linux/linux-postinstall/
- https://docs.docker.com/engine/security/rootless/

### useful commands
```console
$ sudo docker info
$ sudo docker ps
$ sudo docker ps -a
$ sudo docker images
$ sudo docker run --rm -it ubuntu:16.04 /bin/bash
$ sudo docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
$ sudo docker start <u_container_id>
$ sudo docker attach <u_container_id>
$ sudo docker create <u_container_id>
$ sudo docker run -it ubuntu:16.04 bash
$ sudo docker run -dt nginx:latest
$ sudo docker exec -it <u_container_id> bash
$ sudo docker commit <u_container_id> yourname/ubuntu-tmp-file
$ sudo docker tag local-image:tagname new-repo:tagname && sudo docker push new-repo:tagname
$ sudo docker system df
$ sudo docker rm [-f] <u_container_id>
$ sudo docker rm $(docker ps -a q) && echo 'delete all not running containers'
$ sudo docker rmi <image_id>
```
> Ctrl + p, Ctrl + q to detach

> docker run = create + run + attach

> ps axf


### init Google Cloud Account

```console
$ gcloud init
$ gcloud auth application-default login
```
> Credentials saved to file: `~/.config/gcloud/application_default_credentials.json`

### install docker-machine

https://docs.docker.com/machine/install-machine/

```console
$ base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine
$ docker-machine --version
```

### configure env for docker-machine and create docker host

> Enable Compute Engine API before run `docker-machine create ...`

```console
$ export GOOGLE_PROJECT=docker-267311
$ docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-1604-xenial-v20200129 \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
docker-host
$ docker-machine ls
$ eval $(docker-machine env docker-host)
```
> gcloud compute images list --filter="name=ubuntu-1604" --uri

> gcloud compute machine-types list | grep europe-west1-b

###  create reddit image and run container

```console
$ cd dockermonolith/
$ docker build -t reddit:latest .
$ docker images -a
$ docker run --name reddit -d --network=host reddit:latest
$ docker-machine ls
$ gcloud compute firewall-rules create reddit-app \
  --allow tcp:9292 \
  --target-tags=docker-machine \
  --description="Allow PUMA connections" \
  --direction=INGRESS
```

### push image to docker hub repo

```console
$ docker login
$ docker tag reddit:latest dbarsukov/otus-reddit:1.0
$ docker push dbarsukov/otus-reddit:1.0
```

https://hub.docker.com/repository/docker/dbarsukov/otus-reddit/general

> after login docker will create a config file with unencrypted password `~/.docker/config.json`, use cred store to protect data: https://docs.docker.com/engine/reference/commandline/login/#credentials-store

### Ansible, Packer, Terraform

 - add infrastructure as code
 - create gcp inventory file
 - add playbook for docker deployment
 - add playbook for running container with `reddit-app`
 - add packer script for creating image with docker

--------------------------------------------------------

## Docker - 3

- connect to GCE docker-host with docker-machine `eval $(docker-machine env docker-host)`
- create Dockerfile for each microservice
- validate Dockerfile with hadolint, fix remarks
- build images
- play with container network alias and env variables (`$ docker run --env POST_DATABASE_HOST=mongo ...`)
- mount volume (`$ docker volume create reddit_db`, `$ docker run -v reddit_db:/data/db ...`)
- optimize image size

```console
docker build -t dbarsukov/post:1.0 ./post-py
docker build -t dbarsukov/comment:1.0 ./comment
docker build -t dbarsukov/ui:1.0 ./ui

docker network create reddit

docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post dbarsukov/post:1.0
docker run -d --network=reddit --network-alias=comment dbarsukov/comment:1.0
docker run -d --network=reddit -p 9292:9292 dbarsukov/ui:1.0

docker kill $(docker ps -q)

docker run -d --network=reddit --network-alias=mongo mongo:latest
docker run -d --network=reddit --network-alias=post --env POST_DATABASE_HOST=mongo dbarsukov/post:1.0
docker run -d --network=reddit --network-alias=comment --env COMMENT_DATABASE_HOST=mongo dbarsukov/comment:1.0
docker run -d --network=reddit -p 9292:9292 dbarsukov/ui:1.0

docker build -t dbarsukov/ui:2.0 ./ui

docker kill $(docker ps -q)

docker volume create reddit_db

docker run -d --network=reddit --network-alias=mongo -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post --env POST_DATABASE_HOST=mongo dbarsukov/post:1.0
docker run -d --network=reddit --network-alias=comment --env COMMENT_DATABASE_HOST=mongo dbarsukov/comment:1.0
docker run -d --network=reddit -p 9292:9292 dbarsukov/ui:2.0

docker build -t dbarsukov/post:2.0 ./post-py
docker build -t dbarsukov/comment:2.0 ./comment
docker build -t dbarsukov/ui:3.0 ./ui

docker run -d --network=reddit --network-alias=mongo -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post --env POST_DATABASE_HOST=mongo dbarsukov/post:2.0
docker run -d --network=reddit --network-alias=comment --env COMMENT_DATABASE_HOST=mongo dbarsukov/comment:2.0
docker run -d --network=reddit -p 9292:9292 dbarsukov/ui:3.0
```

### Lint Dockerfile

https://www.fromlatest.io/#/ or
https://github.com/hadolint/hadolint

```console
docker pull hadolint/hadolint
docker run --rm -i hadolint/hadolint < Dockerfile
```

--------------------------------------------------------

## Docker - 4

### Docker Networks

Network types:
 - none
 - host
 - bridge

### Experiment no. 1

explore network topology (network types: none, host)
```console
$ docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
$ docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
$ docker-machine ssh docker-host ifconfig
$ docker run --network host -d nginx
```
### Experiment no. 2

explore namespaces
```console
$ sudo ln -s /var/run/docker/netns /var/run/netns
$ sudo ip netns
$ ip netns exec <namespace> <command>
```

### Run containers in bridge network

```console
docker network create reddit --driver bridge

docker run -d --network=reddit --name=mongo_db --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --name=post dbarsukov/post:2.0
docker run -d --network=reddit --name=comment dbarsukov/comment:2.0
docker run -d --network=reddit --name=ui -p 9292:9292 dbarsukov/ui:3.0
```

### Run containers in different networks

```console
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24

docker run -d --network=back_net --name=mongo_db --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=back_net --name=post dbarsukov/post:2.0
docker run -d --network=back_net --name=comment dbarsukov/comment:2.0
docker run -d --network=front_net --name=ui -p 9292:9292 dbarsukov/ui:3.0

docker network connect front_net post
docker network connect front_net comment
```

### Experiment no. 3

explore network topology (network type: bridge)
```console
docker-machine ssh docker-host && sudo apt-get update && sudo apt-get install bridge-utils
docker network ls
ifconfig | grep br
brctl show <interface>
sudo iptables -nL -t nat
ps ax | grep docker-proxy
```

### Docker-compose

- pip install docker-compose
- create `docker-compose.yml` to describe how to build images and run containers with specific order
- create `.env` file for storing parameters like port, user name, image version
- create `docker-compose.override.yml` to override configuration

```console
docker-compose --project-name=reddit up -d
docker-compose ps
```

--------------------------------------------------------

## Gitlab-CI

- add pipeline definition `.gitlab-ci.yml`
- after push commit to gitlab ci repo we can build app docker image, run tests, save image at docker hub, deploy app to new temporary instance, deploy app to dev/stage/prod envs     
- temporary instance will be remove after 1 week or if review has been finished
- every pipeline run will be finished with cleanup job (it will save disk space at runners)
- we can create as many runners as we want by running terraform plus ansible
- integrate gitlab-ci with slack. now we can receive events and alerts to personal channel (https://devops-team-otus.slack.com/archives/CRGMFUEKT)


--------------------------------------------------------

## Monitoring-1

- run prometheus `docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0`
- set targets in `prometheus.yml`
```yaml
---
global:
  scrape_interval: '5s'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
          - 'localhost:9090'

  - job_name: 'ui'
    static_configs:
      - targets:
          - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
          - 'comment:9292'

  - job_name: 'node'
    static_configs:
      - targets:
          - 'node_exporter:9100'

  - job_name: 'mongodb'
    static_configs:
      - targets:
          - 'mongodb_exporter:9216'

  - job_name: 'cloudprober'
    scrape_interval: 10s
    static_configs:
      - targets:
          - 'cloudprober_exporter:9313'
...
```

- create image with new config
```dockerfile
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```

- add to `docker-compose.yml` monitoring section

```yaml
  prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    networks:
      - internal_network
      - external_network
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

 node_exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    networks:
      - internal_network
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'

  mongodb_exporter:
    image: bitnami/mongodb-exporter:${MONGO_EXPORTER_VERSION}
    networks:
      - internal_network
    environment:
      MONGODB_URI: "mongodb://post_db:27017"

  cloudprober_exporter:
    image: ${USERNAME}/cloudprober_exporter
    networks:
      - internal_network
```

-create cloudprober config
```
probe {
    name: "ui_page"
    type: HTTP
    targets {
        host_names: "ui"
    }
    http_probe {
        protocol: HTTP
        port: 9292
    }
    interval_msec: 5000
    timeout_msec: 1000
}

probe {
    name: "comment"
    type: HTTP
    targets {
        host_names: "comment"
    }
    http_probe {
        protocol: HTTP
        port: 9292
    }
    interval_msec: 5000
    timeout_msec: 1000
}
```

- create Dockerfile for cloudprober app
```dockerfile
FROM cloudprober/cloudprober
COPY cloudprober.cfg /etc/cloudprober.cfg
```

- create Makefile for build and push images into Dockerhub
```makefile
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
```

sudo kill -SIGHUP $(pidof dockerd)
tail /var/log/syslog

systemctl status docker
journalctl -xe
