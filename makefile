.DEFAULT_GOAL = all

.PHONY: all
all: build

.PHONY: build
build:
	gxc -ld-options -lmosquitto client.ss

.PHONY: mqtt
mqtt:
	mosquitto -c test/mosquitto.conf

.PHONY: test
test: build
	gerbil test
