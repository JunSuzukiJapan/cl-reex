(defpackage subject-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :subject-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan nil)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer1 (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~A" x)))
    #'(lambda () (add logger "completed 1")) ))

(defparameter observer2 (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~A" x)))
    #'(lambda () (add logger "completed 2")) ))

(defparameter sub (make-subject))

(defparameter subscription1 (subscribe sub observer1))
(defparameter subscription2 (subscribe sub observer2))

(on-next sub 1)
(on-next sub 2)
(on-next sub 3)
(dispose subscription1)
(on-next sub 4)
(on-next sub 5)

(is (result logger)
    '(1 1 2 2 3 3 4 5) )

(finalize)
