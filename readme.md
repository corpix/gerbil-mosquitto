## gerbil-mosquitto

Gerbil Scheme bindings for mosquitto client library for MQTT protocol.

Status:

- Alpha quality, API may change
- Publish, subscribe, wills supported
- TLS should work, but not tested yet
- V5 protocol is not supported yet (maybe in future)


## example

To get started see [example.ss](./example.ss), it may be run from repository root using:

```console
$ make
gxc -ld-options -lmosquitto client-ffi.ss client.ss example.ss
```

```console
$ gxi example.ss
connected!
subscription 1
got a message on topic test with payload hello
got a message on topic test with payload world
```

Mosquitto could be started in separate console using:

> here is the output I've seen during test run of the example

```console
$ make mosquitto
mosquitto -c test/mosquitto.conf
1716692510: No will message specified.
1716692510: Sending CONNACK to auto-6F9A2B51-325B-6CFB-5A16-152335179D88 (0, 0)
1716692510: Received SUBSCRIBE from auto-6F9A2B51-325B-6CFB-5A16-152335179D88
1716692510:     test (QoS 0)
1716692510: Sending SUBACK to auto-6F9A2B51-325B-6CFB-5A16-152335179D88
1716692510: Received PUBLISH from auto-6F9A2B51-325B-6CFB-5A16-152335179D88 (d0, q0, r0, m0, 'test', ... (5 bytes))
1716692510: Sending PUBLISH to auto-6F9A2B51-325B-6CFB-5A16-152335179D88 (d0, q0, r0, m0, 'test', ... (5 bytes))
1716692510: Received PUBLISH from auto-6F9A2B51-325B-6CFB-5A16-152335179D88 (d0, q0, r0, m0, 'test', ... (5 bytes))
1716692510: Sending PUBLISH to auto-6F9A2B51-325B-6CFB-5A16-152335179D88 (d0, q0, r0, m0, 'test', ... (5 bytes))
```

It may be desired to shutdown running mosquitto (to simulate failure) and re-run it again after some time,
in this case following output may be observed to previously shown:

> from `gxi example.ss`

```console
disconnected :(
#<Error #8 continuation: #<continuation #9> message: "No such file or directory" irritants: (14 reconnect) where: #f>
*** Unhandled exception in #<thread #10>

*** ERROR IN ? [Error]: The connection was lost.
--- irritants: 7 loop
--- continuation backtrace:
[0] error
connected!
subscription 4
got a message on topic test with payload hello
got a message on topic test with payload world
```
