(defpackage first-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :first-test)

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
  (element-at 0)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 "completed"))

;; plan 2
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (element-at 3)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(4 "completed"))

;; plan 3 & 4
(reset logger)

(with-observable (observable-empty)
  (element-at 1)
  (subscribe observer)
  (dispose) )

(let ((result (result logger)))
  (is (length result)
      1 )
  (is (type-of (car result))
      'argument-out-of-range-exception ))


(finalize)
