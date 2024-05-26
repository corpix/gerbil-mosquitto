(import :gerbil/gambit
        :std/test
        :std/logger
        :std/event
        :std/sugar
        :std/iter
        :std/format
        :std/misc/ports
        :std/misc/process
        :std/misc/completion
        :std/misc/func
        ./client)
(export client-test test-setup! test-cleanup!)

(deflogger client-test)
(current-logger-options 'info)

(def start-mosquitto? #f)
(def socket-path "./test/mosquitto.sock")
(def pid-path "./test/mosquitto.pid")
(def mosquitto-config-path
  (or (get-environment-variable "MOSQUITTO_CONFIG_PATH")
      "test/mosquitto.conf"))
(def mosquitto-job (void))

(def (start-mosquitto!)
  (for (path [socket-path pid-path])
    (if (file-exists? path)
      (delete-file path)))
  (begin0 (spawn (lambda ()
                   (run-process/batch
                    ["mosquitto" "-c" mosquitto-config-path])))
    (sync (handle-evt 5 (lambda () (error "timed out waiting for mosquitto to start")))
          (spawn (lambda ()
                   (let loop ()
                     (unless (file-exists? pid-path)
                       (thread-sleep! 0.01)
                       (loop))))))))

(def (test-setup!)
  (start-logger!)
  (infof "using lib version ~a" mosquitto-lib-version)
  (when start-mosquitto?
    (set! mosquitto-job (start-mosquitto!)))
  (infof "using mosquitto configuration path ~a" mosquitto-config-path)
  (infof "running mosquitto with pid ~a" (read-file-string pid-path)))

(def (test-cleanup!)
  (when start-mosquitto?
    (run-process ["kill" "-SIGTERM" (read-file-string pid-path)])
    (sync mosquitto-job
          (handle-evt 15 (lambda ()
                           (error "timed out waiting for mosquitto to exit"))))))

;;

(def client-test
  (test-suite "test client"
    (test-case "integration test"
      (def timeout 15)
      (def messages 0)

      (def connected? (void))
      (def messaged? (void))
      (def disconnected? (void))

      (def (init)
        (set! connected? (make-completion 'connected))
        (set! messaged? (make-completion 'message))
        (set! disconnected? (make-completion 'disconnected))
        (spawn (lambda ()
                 (thread-sleep! 999)
                 (completion-error! connected? "timedout")
                 (completion-error! messaged? "timedout")
                 (completion-error! disconnected? "timedout"))))



      (def client
        (make-mosquitto-client
         on-connect: (lambda (client exn)
                       (spawn (lambda ()
                                (if exn (completion-error! connected? exn)
                                    (completion-post! connected? 'done))
                                (displayln 'ret1))))
         on-subscribe: (lambda (client)
                         (displayln 'suibscr))
         on-message: (lambda (client message)
                       (set! messages (+ 1 messages))
                       (when (<= messages 1)
                         (let (payload (mosquitto-message-payload message))
                           (completion-post! messaged? 'done)))
                       (displayln 'ret2))
         on-disconnect: (lambda (client exn)
                          (if exn (completion-error! disconnected? exn)
                              (completion-post! disconnected? 'done)))))

      {client.loop-start!}
      (try
       (test-case "sub-pub"
         (init)
         {client.connect! socket: socket-path}
         (completion-wait! connected?)
         (infof "connected")
         {client.subscribe! "test"}
         (infof "subscribed?")
         {client.publish! "test" (string->utf8 "halo")}
         {client.publish! "test" (string->utf8 "worl")}
         (completion-wait! messaged?)
         (check messages => 2)
         (infof "sent & received messages")
         {client.disconnect!}
         (completion-wait! disconnected?)
         (infof "disconnected"))
       ;; (test-case "reconnect"
       ;;   {client.reconnect!}
       ;;   (check (channel-get connected-ch timeout) => #t)
       ;;   {client.subscribe! "test"}
       ;;   {client.publish! "test" (string->utf8 "halo again")}
       ;;   (check (channel-get messages-ch timeout) => "halo again")
       ;;   {client.disconnect!}
       ;;   (check (channel-get disconnected-ch timeout) => #t)
       ;;   (check messages => 3))
       ;; (test-case "will"
       ;;   ;; fixme: improve this part to check if will really working,
       ;;   ;; I mean not just "ffi call finished without sigsegv"
       ;;   {client.will! "will-test" (string->utf8 "here is the will")}
       ;;   {client.reconnect!}
       ;;   (check (channel-get connected-ch timeout) => #t)
       ;;   {client.disconnect!}
       ;;   (check (channel-get disconnected-ch timeout) => #t))
       (finally {client.loop-stop! #t})))))
