(defpackage synchronize-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :synchronize-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 3)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~S" x)))
    (on-completed () (add logger "completed")) ))

;;
;; plane 1
;;  unneed synchronize test
;;
(with-observable (observable-range 1 3)
  (synchronize)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 "completed") )

;;
;; plan 2
;;  without (synchronize)
;;
(reset logger)

(defparameter observer2 (make-observer
    (on-next (x)
             (case x
               ((0)
                (add logger "0 start")
                (sleep 0.5)
                (add logger "0 end") )
               ((1)
                (add logger "1 start")
                (sleep 0.3)
                (add logger "1 end") )
               ((2)
                (add logger "other start")
                (sleep 0.1)
                (add logger "other end") )))
    (on-error (x) (add logger (format nil "error: ~S" x)))
    (on-completed () (add logger "completed")) ))

(defparameter subscription
      (with-observable (observable-interval 0.1)
        (subscribe observer2) ))

(sleep 1.0)

(dispose subscription)

(is (result logger)
    '("0 start" "1 start" "other start" "other end" "1 end" "0 end") )


;;
;; plan 3
;;  with (synchronize)
;;
(reset logger)

(defparameter observer2 (make-observer
    (on-next (x)
             (case x
               ((0)
                (add logger "0 start")
                (sleep 0.5)
                (add logger "0 end") )
               ((1)
                (add logger "1 start")
                (sleep 0.3)
                (add logger "1 end") )
               ((2)
                (add logger "other start")
                (sleep 0.1)
                (add logger "other end") )))
    (on-error (x) (add logger (format nil "error: ~S" x)))
    (on-completed () (add logger "completed")) ))

(defparameter subscription
  (with-observable (observable-interval 0.1)
    (synchronize)
    (subscribe observer2) ))

(sleep 1.2)

(dispose subscription)

(is (result logger)
    '("0 start" "0 end" "1 start" "1 end" "other start" "other end") )


;; finalize
(finalize)
