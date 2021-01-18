(defpackage observable-start-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-start-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(defvar source (with-observable (observable-start
                  (add logger "background task start")
                  (sleep 0.05)
                  (add logger "background task end")
                  "result string" ) ))

(add logger "subscribe 1")
(defvar subscription (with-observable source
  (subscribe observer) ))

(add logger "sleep 0.1 sec")
(sleep 0.1)

(add logger "dispose")
(dispose subscription)

(add logger "subscribe 2")
(with-observable source
  (subscribe observer)
  (dispose) )
 
(is (result logger)
    '("subscribe 1"
      "background task start"
      "sleep 0.1 sec"
      "background task end"
      "result string"
      "completed"
      "dispose"
      "subscribe 2"
      "result string"
      "completed" ))

(finalize)
