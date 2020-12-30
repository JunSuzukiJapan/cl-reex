(defpackage subscribe-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :subscribe-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter ol (observable-from '(1 2 3 4 5 6 7 8 9 10)))

(defvar observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (x) (add logger (format nil "error: ~S" x)))
		#'(lambda () (add logger "completed")) ))

(subscribe ol observer)

(is (result logger)
    '(1 2 3 4 5 6 7 8 9 10 "completed"))

(finalize)