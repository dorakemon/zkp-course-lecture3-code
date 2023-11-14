IMAGE_NAME := zkmooc-lec3-env

CURRENT_DIR := $(shell pwd)

build:
	docker build -t $(IMAGE_NAME) .
run:
	docker run -it -v $(CURRENT_DIR):/usr/src/app $(IMAGE_NAME) /bin/zsh
.PHONY: build run all
