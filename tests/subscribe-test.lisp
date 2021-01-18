(defpackage subscribe-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :subscribe-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.


;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter ol (observable-from '(1 2 3 4 5 6 7 8 9 10)))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~S" x)))
    (on-completed () (add logger "completed")) ))

(subscribe ol observer)

(plan nil)

(is (result logger)
    '(1 2 3 4 5 6 7 8 9 10 "completed"))

(finalize)
