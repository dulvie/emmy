.PHONY: prod dev
.DEFAULT_GOAL: dev

prod:
	docker build -f Dockerfile.production -t dulvie/emmy .

dev:
	docker build -f Dockerfile.dev -t emmy-dev .
