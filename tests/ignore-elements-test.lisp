(defpackage ignore-elements-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :ignore-elements-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (declare (ignore x)) (add logger (format nil "error")))
    (on-completed () (add logger "completed")) ))

;; plan 1
(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (ignore-elements)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("completed") )

;; plan 2
(reset logger)

(with-observable (observable-empty)
  (first)
  (ignore-elements)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("error") )

(finalize)
