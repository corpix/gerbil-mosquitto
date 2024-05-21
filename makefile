.DEFAULT_GOAL = all

.PHONY: all
all:
	gxc -ld-options -lmosquitto client.ss

.PHONY: mqtt
mqtt:
	mosquitto -c test/mosquitto.conf
