.DEFAULT_GOAL = all

.PHONY: all
all: build

.PHONY: build
build:
	gxc -ld-options -lmosquitto client-ffi.ss client.ss

.PHONY: mosquitto
mosquitto:
	mosquitto -c test/mosquitto.conf

.PHONY: test
test: build
	gerbil test
