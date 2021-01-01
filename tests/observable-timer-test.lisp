(defpackage observable-timer-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-timer-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 3)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (x) (add logger (format nil "error: ~S" x)))
		#'(lambda () (add logger "completed")) ))

;; plan 1
(setq timer (observable-timer 0.1))
(setq subscription (subscribe timer observer))

(sleep 0.15)

(dispose subscription)

(is (result logger)
    '(0) )

;; plan 2
(reset logger)
(setq timer (observable-timer 0.1 0.1))
(setq subscription (subscribe timer observer))

(sleep 0.35)

(dispose subscription)

(is (result logger)
    '(0 1 2) )

;; plan 3
(reset logger)
(setq timer (observable-interval 0.1))
(setq subscription (subscribe timer observer))

(sleep 0.35)

(dispose subscription)

(is (result logger)
    '(0 1 2) )

(finalize)
