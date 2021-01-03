(defpackage observable-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 4)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (x) (add logger (format nil "error: ~S" x)))
		#'(lambda () (add logger "completed")) ))

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (where (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(2 4 6 8 10 "completed"))

;; plan 2

(reset logger)

(with-observable (observable-from #(1 2 3 4 5 6 7 8 9 10))
  (where (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(2 4 6 8 10 "completed"))

;; plan 3

(reset logger)

(with-observable (observable-of 1 2 3 4 5 6 7 8 9 10)
  (where (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(2 4 6 8 10 "completed"))

;; plan 4

(reset logger)

(with-observable (observable-empty)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("completed") )

(finalize)