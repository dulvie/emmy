.PHONY: emmy
.DEFAULT_GOAL: emmy

emmy:
	docker build -t dulvie/emmy .

dev:
	docker build -f Dockerfile.dev -t emmy-dev .
