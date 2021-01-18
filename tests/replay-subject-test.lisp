(defpackage replay-subject-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :replay-subject-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan nil)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer1 (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error-1: ~A" x)))
    (on-completed () (add logger "completed 1")) ))

(defparameter observer2 (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error-2: ~A" x)))
    (on-completed () (add logger "completed 2")) ))

;; plan 1

(defparameter sub (make-replay-subject))

(defparameter subscription1 (subscribe sub observer1))
(defparameter subscription2 (subscribe sub observer2))

(on-next sub 1)
(on-next sub 2)
(on-next sub 3)
(dispose subscription1)
(on-next sub 4)
(on-next sub 5)
(on-completed sub)

(is (result logger)
    '(1 1 2 2 3 3 4 5 "completed 2") )

;; plan 2

(reset logger)

(defparameter sub (make-replay-subject))

(on-next sub 1)
(on-next sub 2)

(subscribe sub observer1)

(on-completed sub)

(subscribe sub observer2)

(is (result logger)
    '(1 2 "completed 1" 1 2 "completed 2") )

;; plan 3

(reset logger)

(defparameter sub (make-replay-subject))

(on-next sub 1)
(on-next sub 2)

(subscribe sub observer1)

(on-error sub "some error")

(subscribe sub observer2)

(is (result logger)
    '(1 2 "error-1: some error" 1 2 "error-2: some error") )


;; finalize
(finalize)
