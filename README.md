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
$ sudo docker run -rm -it ubuntu:16.04 /bin/bash
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

- connect to GCE docker-host with docker-machine `eval ($docker-machine env docker-host)`
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
