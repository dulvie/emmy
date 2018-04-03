.PHONY: prod dev
.DEFAULT_GOAL: dev

dev:
	docker build -f Dockerfile.dev -t emmy-dev .

prod:
	docker build -f Dockerfile.production -t dulvie/emmy .

