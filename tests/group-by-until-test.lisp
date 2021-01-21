(defpackage where-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :where-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

;; plan 1

(defparameter messengers (vector (make-subject)
                                 (make-subject)
                                 (make-subject) ))

(with-observable (observable-range 0 9)
  (group-by-until (x)
                  (mod x 3)
                  (let ((index (mod x 3)))
                    (aref messengers index) ))
  (subscribe (make-observer
              (on-next (g)
                       (subscribe g (make-observer
                         (on-next (x)
                          (add logger (format nil "group-by-until(~A) on-next ~A" (get-key g) x)))
                         (on-error (x)
                          (add logger (format nil "group-by-until(~A) on-error ~A" (get-key g) x)))
                         (on-completed ()
                          (add logger (format nil "group-by-until on-completed")) ))))

              (on-error (err) (add logger (format nil "on-error ~A" err)))
              (on-completed () (add logger (format nil "on-completed"))) ))
  (dispose) )

(is (result logger)
    '("group-by-until(0) on-next 0" "group-by-until(1) on-next 1" "group-by-until(2) on-next 2"
      "group-by-until(0) on-next 3" "group-by-until(1) on-next 4" "group-by-until(2) on-next 5"
      "group-by-until(0) on-next 6" "group-by-until(1) on-next 7" "group-by-until(2) on-next 8"

      "group-by-until on-completed"
      "group-by-until on-completed"
      "group-by-until on-completed"
      "on-completed" ))

;; plan 2
(reset logger)

(defparameter messengers (vector (make-subject)
                                 (make-subject)
                                 (make-subject) ))

(defparameter subject (make-subject))

(with-observable subject
  (group-by-until (x)
                  (mod x 3)
                  (let ((index (mod x 3)))
                    (aref messengers index) ))
  (subscribe (make-observer
              (on-next (g)
                       (subscribe g (make-observer
                         (on-next (x)
                          (add logger (format nil "group-by-until(~A) on-next ~A" (get-key g) x)))
                         (on-error (x)
                          (add logger (format nil "group-by-until(~A) on-error ~A" (get-key g) x)))
                         (on-completed ()
                          (add logger (format nil "group-by-until(~A) on-completed" (get-key g))) ))))

              (on-error (err) (add logger (format nil "on-error ~A" err)))
              (on-completed () (add logger (format nil "on-completed"))) )) )

(on-next subject 0)
(on-next subject 1)
(on-next subject 2)
(on-next subject 3)
(on-completed (aref messengers 2))
(on-next subject 4)
(on-next subject 5)
(on-completed (aref messengers 0))
(on-next subject 6)
(on-next subject 7)
(on-next subject 8)
(on-completed (aref messengers 1))
(on-next subject 9)

(on-completed subject)

(is (result logger)
    '("group-by-until(0) on-next 0"
      "group-by-until(1) on-next 1"
      "group-by-until(2) on-next 2"
      "group-by-until(0) on-next 3"
      "group-by-until(2) on-completed"
      "group-by-until(1) on-next 4"
      "group-by-until(0) on-completed"
      "group-by-until(1) on-next 7"
      "group-by-until(1) on-completed"
      "on-completed" ))

;; finalize
(finalize)
