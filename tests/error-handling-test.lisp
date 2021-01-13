(defpackage error-handling-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :error-handling-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan nil)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (declare (ignore x)) (add logger (format nil "caught error.")))
    #'(lambda () (add logger "completed")) ))

;; plan 1
(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 2
(reset logger)

(with-observable (observable-from #(1 2 3 4 5 6 7 8 9 10))
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 3
(reset logger)

(with-observable (observable-of 1 2 3)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 4
(reset logger)

(with-observable (observable-empty)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "completed") )

;; plan 5
(reset logger)

(with-observable (observable-never)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    nil )

;; plan 6
(reset logger)

(with-observable (observable-from "Hello, World!")
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 7
(reset logger)

(defvar str-stream (make-string-input-stream "Hello, World!"))
(with-observable (observable-from str-stream)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 8
(reset logger)

(with-observable (observable-throw "My-Error")
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 9
(reset logger)

(with-observable (handmade-observable
    (on-next 1)
    (on-next 2)
    (on-next 3)
    (on-completed) )
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )


;; plan 10
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10 1 2 3 4 5))
  (skip-while (x) (< x 5))
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 11
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (skip 2)
  (take 5)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 12
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10 1 2 3 4 5))
  (take-while (x) (< x 9))
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 13
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (where (x) (oddp x))
  (take 3)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 14
(reset logger)

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
(on-error sub "some error")

(is (result logger)
    '(1 1 2 2 3 3 4 5 "error: some error") )

;; plan 15
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (where (x) (evenp x))
  (select (x) (* x x))
  (take 2)
  (repeat 3)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;; plan 16
(reset logger)

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (last)
  (where (x)
         (declare (ignore x))
         (error "test") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '( "caught error.") )

;;
;; finalize
;;
(finalize)
