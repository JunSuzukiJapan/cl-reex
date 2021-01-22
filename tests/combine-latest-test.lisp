(defpackage combine-latest-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :combine-latest-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

(defparameter subject1 (make-subject))
(defparameter subject2 (make-subject))

(with-observable subject1
  (combine-latest subject2)
  (subscribe observer) )

(on-next subject1 "foo")
(on-next subject2 100)
(on-next subject2 200)
(on-next subject1 "bar")
(on-next subject1 "zot")
(on-next subject2 300)
(on-completed subject1)
(on-next subject2 400)
(on-completed subject2)

(is (result logger)
    '(("foo" 100)
      ("foo" 200)
      ("bar" 200)
      ("zot" 200)
      ("zot" 300)
      ("zot" 400)
      "completed" )
    :test #'equalp )

(finalize)
