(import :gerbil/gambit
        :std/test
        :std/logger
        :std/event
        :std/sugar
        :std/iter
        :std/format
        :std/misc/ports
        :std/misc/process
        :std/misc/func
        ./client)
(export client-test test-setup! test-cleanup!)

(deflogger client-test)
(current-logger-options 'info)

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
  (set! mosquitto-job (start-mosquitto!))
  (infof "using mosquitto configuration path ~a" mosquitto-config-path)
  (infof "running mosquitto with pid ~a" (read-file-string pid-path)))

(def (test-cleanup!)
  (run-process ["kill" "-SIGTERM" (read-file-string pid-path)])
  (sync (handle-evt 5 (lambda () (error "mosquitto termination timeout")))
        mosquitto-job))

;;

(def client-test
  (test-suite "test client"
    (test-case "integration test"
      (def connected #f)
      (def messages 0)
      (def disconnected #f)
      (def (assert-loop-error exn)
        (check (any-of '((lost) (loop)) (error-irritants exn)) => #t))
      (def client
        (make-mosquitto-client
         on-connect: (lambda (client) (set! connected #t))
         on-message: (lambda (client message) (set! messages (+ 1 messages)))
         on-disconnect: (lambda (client) (set! disconnected #t))))
      (check (sync (handle-evt 1 void) mosquitto-job) => (void))
      {client.connect! socket: socket-path}
      (def job {client.spawn on-error: assert-loop-error})
      {client.subscribe! "test"}
      {client.publish! "test" (string->utf8 "halo")}
      {client.publish! "test" (string->utf8 "worl")}
      (sync (handle-evt 1 void) job)
      {client.disconnect!}
      (sync (handle-evt 1 void) job)
      (check connected => #t)
      (check disconnected => #t)
      (check messages => 2))))
