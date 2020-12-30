(defpackage take-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :take-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defvar observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (x) (add logger (format nil "error: ~S" x)))
		#'(lambda () (add logger "completed")) ))

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (where (x) (oddp x))
  (take 3)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 3 5 "completed"))

(finalize)