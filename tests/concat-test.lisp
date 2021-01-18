(defpackage concat-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :concat-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 3)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(with-observable (observable-range 1 3)
  (concat (observable-range 5 5))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 5 6 7 8 9 "completed") )

;; plan 2
(reset logger)

(with-observable (observable-range 1 3)
  (concat)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 "completed") )

;; plan 3
(reset logger)

(with-observable (observable-range 1 3)
  (concat (observable-range 5 5)
          (observable-of 20 22 24)
          (observable-empty)
          (observable-from '(50 100 200)) )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3
      5 6 7 8 9
      20 22 24
      50 100 200
      "completed" ))

(finalize)
