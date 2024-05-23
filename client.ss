(import :std/foreign
        :std/sugar)
(export make-mosquitto-client
        mosquitto-clients
        mosquitto-client
        mosquitto-client?
        mosquitto-client-ptr
        mosquitto-client-user-data
        mosquitto-client-on-connect
        mosquitto-client-on-disconnect
        mosquitto-client-on-publish
        mosquitto-client-on-message
        mosquitto-client-on-subscribe
        mosquitto-client-on-unsubscribe
        mosquitto-client-on-log
        mosquitto-message
        mosquitto-message?
        mosquitto-message-id
        mosquitto-message-topic
        mosquitto-message-payload
        mosquitto-message-qos
        mosquitto-message-retain

        mosquitto-lib-version)

;; note: have no idea why it is not working like this (begin-ffi (mosquitto* ...) ...)
;; so just including ffi here to simplify things
(include "client-ffi.ss")
(begin-ffi (mosquitto-client-ptr
            mosquitto-client-on-connect
            mosquitto-client-on-disconnect
            mosquitto-client-on-publish
            mosquitto-client-on-message
            mosquitto-client-on-subscribe
            mosquitto-client-on-unsubscribe
            mosquitto-client-on-log
            mosquitto-clients-ref
            mosquitto-log-levels
            make-mosquitto-message

            on_connect
            on_disconnect
            on_publish
            on_message
            on_subscribe
            on_unsubscribe
            on_log)
  (c-define (on_connect ptr user-data rc) (mosquitto* (pointer void) int)
            void "mosquitto_on_connect" ""
            (unless (eq? rc CONNACK_ACCEPTED)
              (error (mosquitto_connack_string rc)
                (cond
                 ((= rc CONNACK_REFUSED_NOT_AUTHORIZED) 'not-authorized)
                 ((= rc CONNACK_REFUSED_BAD_USERNAME_PASSWORD) 'bad-username-password)
                 ((= rc CONNACK_REFUSED_SERVER_UNAVAILABLE) 'server-unavailable)
                 ((= rc CONNACK_REFUSED_IDENTIFIER_REJECTED) 'identifier-rejected)
                 ((= rc CONNACK_REFUSED_PROTOCOL_VERSION) 'protocol-version)
                 (else 'unknown))))
            (let* ((client (mosquitto-clients-ref ptr))
                   (callback (mosquitto-client-on-connect client)))
              (when (procedure? callback)
                (callback client))))
  (c-define (on_disconnect ptr user-data rc) (mosquitto* (pointer void) int)
            void "mosquitto_on_disconnect" ""
            (unless (eq? rc MOSQ_ERR_SUCCESS)
              (error (mosquitto_strerror rc)
                (cond
                 ;; todo: not sure about set of this consts, need to test various disconnect reasons
                 ((= rc MOSQ_ERR_CONN_REFUSED) 'refused)
                 ((= rc MOSQ_ERR_CONN_LOST) 'lost)
                 (else 'unknown))))
            (let* ((client (mosquitto-clients-ref ptr))
                   (callback (mosquitto-client-on-disconnect client)))
              (when (procedure? callback)
                (callback client))))
  (c-define (on_publish ptr user-data mid) (mosquitto* (pointer void) int)
            void "mosquitto_on_publish" ""
            (let* ((client (mosquitto-clients-ref ptr))
                   (callback (mosquitto-client-on-publish client)))
              (when (procedure? callback)
                (callback client mid))))
  (c-define (on_message ptr user-data message) (mosquitto* (pointer void) mosquitto_message*)
            void "mosquitto_on_message" ""
            (let* ((client (mosquitto-clients-ref ptr))
                   (callback (mosquitto-client-on-message client)))
              (when (procedure? callback)
                (callback client
                          (let* ((len (mosquitto_message_payloadlen message))
                                 (blob (void)))
                            (unless (zero? len)
                              (set! blob (make-u8vector len))
                              (mosquitto_message_payload_get message blob))
                            (make-mosquitto-message
                             (mosquitto_message_mid message)
                             (mosquitto_message_topic message)
                             blob
                             (mosquitto_message_qos message)
                             (mosquitto_message_retain message)))))))
  (c-define (on_subscribe ptr user-data mid qos-count granted-qos) (mosquitto* (pointer void) int int (pointer int))
            ;; todo: should we pass qos-count & granted-qos to user? looks like very low-level kind of things
            ;; maybe through dynamic scope to make them optional?
            void "mosquitto_on_subscribe" ""
            (let* ((client (mosquitto-clients-ref ptr))
                   (callback (mosquitto-client-on-subscribe client)))
              (when (procedure? callback)
                (callback client mid))))
  (c-define (on_unsubscribe ptr user-data mid) (mosquitto* (pointer void) int)
            void "mosquitto_on_unsubscribe" ""
            (let* ((client (mosquitto-clients-ref ptr))
                   (callback (mosquitto-client-on-unsubscribe client)))
              (when (procedure? callback)
                (callback client mid))))
  (c-define (on_log ptr user-data level str) (mosquitto* (pointer void) int char-string)
            void "mosquitto_on_log" ""
            (let* ((client (mosquitto-clients-ref ptr))
                   (callback (mosquitto-client-on-log client)))
              (when (procedure? callback)
                (let ((level-name (assoc level mosquitto-log-levels)))
                  (callback client (cdr level-name) str))))))

;;

(def (assert-errno result)
  (if (null? result)
    (error (mosquitto_strerror MOSQ_ERR_ERRNO))
    result))

(def (assert-ret-code rc (context #f))
  (if (eq? rc MOSQ_ERR_SUCCESS)
    rc
    (error (mosquitto_strerror rc) context)))

;;

(def mosquitto-log-levels
    (list [MOSQ_LOG_INFO . 'log-info]
          [MOSQ_LOG_NOTICE . 'log-notice]
          [MOSQ_LOG_WARNING . 'log-warning]
          [MOSQ_LOG_ERR . 'log-err]
          [MOSQ_LOG_DEBUG . 'log-debug]))

;;

(def mosquitto-clients
  (make-table weak-keys: #t weak-values: #t))

(def (mosquitto-client-register! mosquitto)
  (table-set! mosquitto-clients
              (foreign-address (mosquitto-client-ptr mosquitto))
              mosquitto))

(def (mosquitto-clients-ref ptr)
  (table-ref mosquitto-clients (foreign-address ptr)))

;;

(defstruct mosquitto-client
  (ptr
   user-data
   on-connect
   on-disconnect
   on-publish
   on-message
   on-subscribe
   on-unsubscribe
   on-log)
  constructor: :init!)

(defmethod {:init! mosquitto-client}
  (lambda (self id: (id #f)
                clean-session: (clean-session #t)
                user-data: (user-data #f)
                on-connect: (on-connect #f)
                on-disconnect: (on-disconnect #f)
                on-publish: (on-publish #f)
                on-message: (on-message #f)
                on-subscribe: (on-subscribe #f)
                on-unsubscribe: (on-unsubscribe #f)
                on-log: (on-log #f))
    (let ((ptr (assert-errno (mosquitto_new id clean-session #f))))
      (set! (@ self ptr) ptr)
      (set! (@ self user-data) user-data)
      (mosquitto-client-register! self)
      (make-will ptr
                 (lambda (ptr) ;; todo: unregister here?
                   (mosquitto_destroy ptr)))
      (mosquitto_connect_callback_set ptr on_connect)
      (mosquitto_disconnect_callback_set ptr on_disconnect)
      (mosquitto_publish_callback_set ptr on_publish)
      (mosquitto_message_callback_set ptr on_message)
      (mosquitto_subscribe_callback_set ptr on_subscribe)
      (mosquitto_unsubscribe_callback_set ptr on_unsubscribe)
      (mosquitto_log_callback_set ptr on_log)
      (set! (@ self on-connect) on-connect)
      (set! (@ self on-disconnect) on-disconnect)
      (set! (@ self on-publish) on-publish)
      (set! (@ self on-message) on-message)
      (set! (@ self on-subscribe) on-subscribe)
      (set! (@ self on-unsubscribe) on-unsubscribe)
      (set! (@ self on-log) on-log)
      self)))

(defmethod {connect! mosquitto-client}
  (lambda (self socket: (socket #f)
                host: (host "127.0.0.1")
                port: (port 1883)
                username: (username #f)
                password: (password #f)
                keepalive: (keepalive 5)
                bind-address: (bind-address #f)
                tls-cafile: (tls-cafile #f)
                tls-capath: (tls-capath #f)
                tls-certfile: (tls-certfile #f)
                tls-keyfile: (tls-keyfile #f)
                tls-insecure: (tls-insecure #f)
                tls-ocsp-required: (tls-ocsp-required #f)
                tls-use-os-certs: (tls-use-os-certs #f)
                tls-alpn: (tls-alpn #f)
                socks5-host: (socks5-host #f)
                socks5-port: (socks5-port 1080)
                socks5-username: (socks5-username #f)
                socks5-password: (socks5-password #f)
                reconnect-delay: (reconnect-delay 1)
                reconnect-delay-max: (reconnect-delay-max 10)
                reconnect-exp-backoff: (reconnect-exp-backoff #t)
                tcp-nodelay: (tcp-nodelay #t))
    (begin0 self
      (let ((ptr (mosquitto-client-ptr self)))
        (when socket
          (set! host socket)
          (set! port 0))
        (when (and username password)
          (assert-ret-code
           (mosquitto_username_pw_set ptr username password)
           'username/password))
        (when (or tls-cafile tls-capath tls-certfile tls-keyfile)
          (assert-ret-code
           (mosquitto_tls_set ptr tls-cafile tls-capath
                              tls-certfile tls-keyfile
                              #f)
           'tls))
        (unless tls-insecure
          (assert-ret-code
           (mosquitto_tls_insecure_set ptr #f)
           'tls-insecure))
        (when tls-ocsp-required
          (assert-ret-code
           (mosquitto_int_option ptr
                                 MOSQ_OPT_TLS_OCSP_REQUIRED
                                 1)
           'tls-ocsp-required))
        (when tls-use-os-certs
          (assert-ret-code
           (mosquitto_int_option ptr
                                 MOSQ_OPT_TLS_USE_OS_CERTS
                                 1)
           'tls-use-os-certs))
        (when tls-alpn
          (assert-ret-code
           (mosquitto_string_option ptr
                                    MOSQ_OPT_TLS_ALPN
                                    tls-alpn)
           'tls-alpn))
        (when bind-address
          (assert-ret-code
           (mosquitto_string_option ptr
                                    MOSQ_OPT_BIND_ADDRESS
                                    bind-address)
           'bind-address))
        (when socks5-host
          (assert-ret-code
           (mosquitto_socks5_set ptr
                                 socks5-host socks5-port
                                 socks5-username socks5-password)
           'socks5))
        (when tcp-nodelay
          (assert-ret-code
           (mosquitto_int_option ptr MOSQ_OPT_TCP_NODELAY 1)
           'tcp-nodelay))
        (assert-ret-code
         (mosquitto_reconnect_delay_set ptr
                                        reconnect-delay reconnect-delay-max
                                        reconnect-exp-backoff)
         'reconnect-delay)
        (assert-ret-code
         (mosquitto_connect ptr host port keepalive)
         'connect)))))

(defmethod {subscribe! mosquitto-client}
  (lambda (self sub (qos 0))
    (let (mid (mosquitto_make_int_ptr))
      (assert-ret-code (mosquitto_subscribe self.ptr mid sub qos)
                       'subscribe)
      (int*->number mid))))

(defmethod {unsubscribe! mosquitto-client}
  (lambda (self sub)
    (let (mid (mosquitto_make_int_ptr))
      (assert-ret-code (mosquitto_unsubscribe self.ptr mid sub)
                       'unsubscribe)
      (int*->number mid))))

(defmethod {publish! mosquitto-client}
  (lambda (self topic payload qos: (qos 0) retain: (retain #f))
    (let ((mid (mosquitto_make_int_ptr))
          (len (if (void? payload) 0 (u8vector-length payload))))
      (assert-ret-code (mosquitto_publish self.ptr mid topic len payload qos retain)
                       'publish)
      (int*->number mid))))

(defmethod {disconnect! mosquitto-client}
  (lambda (self)
    (assert-ret-code (mosquitto_disconnect self.ptr) 'disconnect)))

(defmethod {loop mosquitto-client}
  (lambda (self (timeout 1000))
    (assert-ret-code (mosquitto_loop self.ptr timeout 1) 'loop)))

(defmethod {loop-forever mosquitto-client}
  (lambda (self (timeout 1000))
    (assert-ret-code (mosquitto_loop_forever self.ptr timeout 1) 'loop-forever)))

(defmethod {spawn mosquitto-client}
  (lambda (self wait-timeout: (wait-timeout 10)
                on-error: (on-error void))
    (spawn
     (lambda ()
       (let loop ()
         (def result
           (try {self.loop wait-timeout}
                (thread-yield!)
                (catch (exn) exn)))
         (if (error? result) (on-error result)
             (loop)))))))

;;

(def mosquitto-lib-version
  (let ((major (mosquitto_make_int_ptr))
        (minor (mosquitto_make_int_ptr))
        (rev (mosquitto_make_int_ptr)))
    (mosquitto_lib_version major minor rev)
    (list (int*->number major)
          (int*->number minor)
          (int*->number rev))))

;;

(defstruct mosquitto-message
  (id topic payload qos retain)
  transparent: #t)
