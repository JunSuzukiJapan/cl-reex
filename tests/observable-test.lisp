(defpackage observable-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 8)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

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

;; plan 5

(reset logger)

(with-observable (observable-never)
  (subscribe observer)
  (dispose) )

(is (result logger)
    nil )

;; plan 6
(reset logger)

(with-observable (observable-from "Hello, World!")
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(#\H #\e #\l #\l #\o #\, #\Space #\W #\o #\r #\l #\d #\! "completed") )

;; plan 7
(reset logger)

(defvar str-stream (make-string-input-stream "Hello, World!"))
(with-observable (observable-from str-stream)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(#\H #\e #\l #\l #\o #\, #\Space #\W #\o #\r #\l #\d #\! "completed") )

;; plan 8
(reset logger)

(with-observable (observable-throw "My-Error")
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("error: My-Error") )

(finalize)
