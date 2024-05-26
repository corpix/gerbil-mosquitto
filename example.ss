(import :std/sugar
        :std/format
        :std/error
        :std/event
        :mosquitto/client)

(def (on-connect client exn)
  (displayln "connected!")
  {client.subscribe! "test"}
  {client.publish! "test" (string->utf8 "hello")}
  {client.publish! "test" (string->utf8 "world")})

(def (on-subscribe client mid)
  (displayln (format "subscription ~a" mid)))

(def (on-message client message)
  (displayln (format "got a message on topic ~a with payload ~a"
                     (@ message topic)
                     (utf8->string (@ message payload)))))

(def (on-disconnect client exn)
  (displayln "disconnected :(")
  (let lp ((error-shown? #f))
    (try {client.reconnect!}
         {client.loop!}
         (catch (e)
           (unless error-shown? (displayln e))
           (thread-sleep! 2)
           (lp #t)))))

;;

(def client
  (make-mosquitto-client
   on-connect: on-connect
   on-subscribe: on-subscribe
   on-message: on-message
   on-disconnect: on-disconnect))
{client.loop!}
{client.connect! socket: "./test/mosquitto.sock"}

(sync (handle-evt 999999 void))