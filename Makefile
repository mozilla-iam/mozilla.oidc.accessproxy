IMAGE_NAME		:= "mozilla.oidc.accessproxy"
PORTS			:= "-p 80:80 -p 443:443"
HUB_URL			:= "656532927350.dkr.ecr.us-west-2.amazonaws.com"
COMPOSE_CMD		:= "up"
discovery_url	:=
backend     	:= "http://localhost:5000"
client_id   	:=
client_secret	:=
httpsredir		:= "yes"
sessionsecret	:=
cookiename		:= "session"
allowed_group	:=

all: help

help:
	@echo "Makefile configuration and targets:"
	@echo
	@grep '^[^#[:space:]].*:' Makefile

build: Dockerfile
	docker build --build-arg GITCACHE=$(shell date +%s) -t $(IMAGE_NAME) .

compose: compose/docker-compose.base.yml
	touch compose/local.env
	docker-compose -f compose/docker-compose.base.yml -f compose/docker-compose.rebuild.yml -f compose/docker-compose.dev.yml $(COMPOSE_CMD)

compose-detach: compose/docker-compose.base.yml
	touch compose/local.env
	docker-compose -f compose/docker-compose.base.yml -f compose/docker-compose.rebuild.yml -f compose/docker-compose.dev.yml $(COMPOSE_CMD) --detach

compose-staging: compose/docker-compose.base.yml
	touch compose/local.env
	docker-compose -f compose/docker-compose.base.yml -f compose/docker-compose.norebuild.yml -f compose/docker-compose.stg.yml $(COMPOSE_CMD)

compose-production: compose/docker-compose.base.yml
	touch compose/local.env
	docker-compose -f compose/docker-compose.base.yml -f compose/docker-compose.norebuild.yml -f compose/docker-compose.prod.yml $(COMPOSE_CMD)

run: Dockerfile
	docker run -i \
	  $(PORTS) \
	  -e discovery_url \
	  -e backend \
	  -e client_id \
	  -e client_secret \
	  -e httpsredir \
	  -e sessionsecret \
	  -e cookiename \
	  -e allowed_group \
	  -t $(IMAGE_NAME)

hublogin: Dockerfile build tag
	docker login
	docker push $(HUB_URL)/$(IMAGE_NAME):latest

awslogin: Dockerfile build tag
	# See also https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/firstRun
	# If you do not yet have a HUB_URL and repository created you'll have to do so above
	@echo "Logging you in the hub at $(HUB_URL)"
	aws ecr get-login --no-include-email --region us-west-2  | grep -v MFA | bash
	docker push $(HUB_URL)/$(IMAGE_NAME):latest

tag:
	docker tag $(IMAGE_NAME):latest $(HUB_URL)/$(IMAGE_NAME):latest

.PHONY: help build run awslogin compose compose-detach compose-staging compose-production
