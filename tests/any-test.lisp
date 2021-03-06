(defpackage any-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :any-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (any (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(t "completed") )

;; plan 2
(reset logger)

(with-observable (observable-of 1 3 5 7 9)
  (any (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(nil "completed") )

;; finalize
(finalize)
