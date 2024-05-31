.DEFAULT_GOAL = all

version := $(shell date +"%Y-%m-%d").$(shell git rev-list --count HEAD)

.PHONY: all
all: build

.PHONY: build
build:
	gxc -ld-options -lmosquitto client-ffi.ss client.ss example.ss

.PHONY: mosquitto
mosquitto:
	mosquitto -c test/mosquitto.conf

.PHONY: test
test: build
	gerbil test

.PHONY: tag
tag:
	git tag v$(version)
