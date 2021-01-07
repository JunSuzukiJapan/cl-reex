(defpackage logger-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :logger-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 3)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(add logger 1)
(add logger 2)
(add logger 3)
(is (result logger) '(1 2 3))

(add logger 1)
(add logger 2)
(add logger 3)
(is (result logger) '(1 2 3 1 2 3))

(reset logger)
(add logger 1)
(add logger 2)
(add logger 3)
(is (result logger) '(1 2 3))

(finalize)
