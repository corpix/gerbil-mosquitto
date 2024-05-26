(import :std/sugar
        :std/format
        :std/error
        :std/event
        :mosquitto/client)

(def (on-connect client exn)
  (displayln "connected!")
  {client.subscribe! "test"})

(def (on-message client message)
  (displayln (format "got a message on topic ~a with payload ~a"
                     (@ message topic)
                     (utf8->string (@ message payload)))))

(def (on-disconnect client exn)
  (displayln "disconnected :(")
  ;; try to reconnect, it will reconnect automatically,
  ;; no need to call it more than once after disconnect
  ;; it will show an error immediatelly
  (try {client.reconnect!}
       (catch (e) (displayln e))))

;;

(def client
  (make-mosquitto-client
   on-connect: on-connect
   on-message: on-message
   on-disconnect: on-disconnect))
{client.loop-start!}
{client.connect! socket: "./test/mosquitto.sock"}
{client.publish! "test" (string->utf8 "hello")}
{client.publish! "test" (string->utf8 "world")}

(sync (handle-evt 999999 void))