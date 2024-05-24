(import :std/sugar
        :std/format
        :std/error
        :std/event
        :mosquitto/client)

(def mosquitto-loop (void))
(def client
  (make-mosquitto-client
   on-connect: (lambda (client) (displayln "connected!"))
   on-message: (lambda (client message)
                 (displayln (format "got a message on topic ~a with payload ~a"
                                    (@ message topic)
                                    (utf8->string (@ message payload)))))
   on-disconnect: (lambda (client) (displayln "disconnected :("))))

{client.connect! socket: "./test/mosquitto.sock"}

(set! mosquitto-loop {client.spawn})

{client.subscribe! "test"}
{client.publish! "test" (string->utf8 "hello")}
{client.publish! "test" (string->utf8 "world")}

(let loop ()
  (sync mosquitto-loop)
  (try {client.reconnect!}
       (set! mosquitto-loop {client.spawn})
       (catch (exn)
         (displayln exn)
         (thread-sleep! 2))
       (finally (loop))))