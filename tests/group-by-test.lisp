(defpackage where-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :where-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(with-observable (observable-range 0 9)
  (group-by (x) (mod x 3))
  (subscribe (make-observer
              (on-next (g)
                       (subscribe g (make-observer
                         (on-next (x)
                          (add logger (format nil "group-by(~A) on-next ~A" (get-key g) x)))
                         (on-error (x)
                          (add logger (format nil "group-by(~A) on-error ~A" (get-key g) x)))
                         (on-completed ()
                          (add logger (format nil "group-by(~A) on-completed" (get-key g))) ))))

              (on-error (err) (add logger (format nil "on-error ~A" err)))
              (on-completed () (add logger (format nil "on-completed"))) ))
  (dispose) )

(is (result logger)
    '("group-by(0) on-next 0" "group-by(1) on-next 1" "group-by(2) on-next 2"
      "group-by(0) on-next 3" "group-by(1) on-next 4" "group-by(2) on-next 5"
      "group-by(0) on-next 6" "group-by(1) on-next 7" "group-by(2) on-next 8"

      "group-by(0) on-completed"
      "group-by(1) on-completed"
      "group-by(2) on-completed"
      "on-completed" ))

;; finalize
(finalize)
