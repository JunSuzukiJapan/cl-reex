(defpackage take-until-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :take-until-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; plan 1

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (x) (add logger (format nil "error: ~S" x)))
		#'(lambda () (add logger "completed")) ))

(defparameter sub (make-subject))
(defparameter end-trigger (make-subject))

(with-observable sub
  (take-until end-trigger)
  (subscribe observer) )

(foreach (observable-range 1 5)
	 #'(lambda (x) (on-next sub x)) )

(on-next end-trigger 1)

(foreach (observable-range 6 5)
	 #'(lambda (x) (on-next sub x)) )

(is (result logger)
    '(1 2 3 4 5) )

(finalize)
