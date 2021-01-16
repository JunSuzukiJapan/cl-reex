(defpackage scan-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :scan-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 5)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (err) (add logger err))
    #'(lambda () (add logger "completed")) ))

;; plan 1

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (scan (x y) (+ x y))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 3 6 10 15 21 28 36 45 55 "completed") )

;; plan 2
(reset logger)

(with-observable (observable-just 1)
  (scan (x y) (+ x y))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 "completed") )

;; plan 3 & 4
(reset logger)

(with-observable (observable-empty)
  (scan (x y) (+ x y))
  (subscribe observer)
  (dispose) )

(let ((result (result logger)))
  (is (length result)
      1 )
  (is (type-of (car result))
      'sequence-contains-no-elements-error ))

;; plan 5
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (scan :init 100 (x y) (+ x y))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(101 103 106 110 115 121 128 136 145 155 "completed") )

(finalize)
