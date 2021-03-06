(defpackage skip-while-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :skip-while-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~S" x)))
    (on-completed () (add logger "completed")) ))

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10 1 2 3 4 5))
  (skip-while (x) (< x 5))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(5 6 7 8 9 10 1 2 3 4 5 "completed"))

;; plan 2

(reset logger)

(with-observable (observable-from '(1 2 3 4 5 1 2 3 4 5))
  (skip-while (x) (< x 3))
  (repeat 2)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(3 4 5 1 2 3 4 5 3 4 5 1 2 3 4 5 "completed"))

(finalize)
