.PHONY: prod dev
.DEFAULT_GOAL: dev

dev:
	docker build -f Dockerfile.dev -t emmy-dev .

run: dev
	docker-compose up -d
	docker-compose exec emmy /bin/bash

TAG ?= registry.dlv/dulvie/emmy
prod:
	docker build -f Dockerfile.production -t $(TAG) .

release: prod
	docker push $(TAG)

build_docker_multiarch:
	docker buildx build -f Dockerfile.production --platform linux/arm64,linux/amd64 -t '$(TAG)' --push .
