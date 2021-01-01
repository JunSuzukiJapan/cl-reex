(defpackage observable-timer-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-timer-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (x) (add logger (format nil "error: ~S" x)))
		#'(lambda () (add logger "completed")) ))

;; plan 1
(setq timer (observable-timer 1))
(setq subscription (subscribe timer observer))

(sleep 1.5)

(dispose subscription)

(is (result logger)
    '(0) )

;; plan 2
(reset logger)
(setq timer (observable-timer 1 1))
(setq subscription (subscribe timer observer))

(sleep 3.5)

(dispose subscription)

(is (result logger)
    '(0 1 2) )

(finalize)
