(defpackage last-test
  (:use :cl
	:cl-reex
	:cl-reex-test.logger
        :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :last-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 4)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
		#'(lambda (x) (add logger x))
		#'(lambda (err) (add logger err))
		#'(lambda () (add logger "completed")) ))

;; plan 1

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (last)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(10 "completed"))

;; plan 2
(reset logger)

(with-observable (observable-range 1 5)
  (last (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(4 "completed"))

;; plan 3 & 4
(reset logger)

(with-observable (observable-empty)
  (last)
  (subscribe observer)
  (dispose) )

(let ((result (result logger)))
  (is (length result)
      1 )
  (is (type-of (car result))
      'sequence-contains-no-elements-error ))

(finalize)
