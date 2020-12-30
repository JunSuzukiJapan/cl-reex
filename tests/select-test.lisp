(defpackage select-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :select-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defvar observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (x) (add logger (format nil "error: ~S" x)))
		#'(lambda () (add logger "completed")) ))

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (where (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(2 4 6 8 10 "completed"))

(finalize)
