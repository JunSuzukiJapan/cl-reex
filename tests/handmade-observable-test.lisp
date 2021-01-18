(defpackage handmade-observable-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :handmade-observable-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; plan 1

(defparameter logger (make-instance 'logger))

(defparameter source (observable-range 1 10))

(defparameter observer (make-observer
		(on-next (x) (add logger x))
		(on-error (x) (add logger (format nil "error: ~S" x)))
		(on-completed () (add logger "completed")) ))

(with-observable (handmade-observable
        (on-next 1)
        (on-next 2)
        (on-error "Error")
        (on-next 3)
        (on-completed) )
    (subscribe observer)
    (dispose) )

(is (result logger)
    '(1 2 "error: \"Error\""))

;; plan 2

(reset logger)
(with-observable (handmade-observable
        (on-next 1)
        (on-next 2)
        (on-next 3)
        (on-completed) )
    (subscribe observer)
    (dispose) )

(is (result logger)
    '(1 2 3 "completed"))

(finalize)
