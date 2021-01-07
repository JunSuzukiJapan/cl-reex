(defpackage fixed-size-queue-test
  (:use :cl
    :cl-reex
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :fixed-size-queue-test)

(plan nil)

(defparameter q (make-queue 3))

;; plan 1
(is (is-empty q)
    t )

;; plan 2
(enqueue q 1)
(is (is-empty q)
    nil )

;; plan 3
(enqueue q 2)
(is (is-empty q)
    nil )

;; plan 4
(is (dequeue q)
    1 )

;; plan 5
(is (dequeue q)
    2 )

;; plan 6
(is (is-empty q)
    t )

;; plan 7
(enqueue q 3)
(enqueue q 4)
(enqueue q 5)
(enqueue q 6)
(enqueue q 7)
(is (is-empty q)
    nil )

;; plan 8
(is (dequeue q)
    5 )
;; plan 9
(is (dequeue q)
    6 )
;; plan 10
(is (dequeue q)
    7 )
;; plan 11
(is (is-empty q)
    t )

(finalize)
