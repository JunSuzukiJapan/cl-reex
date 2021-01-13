(in-package :cl-user)
(defpackage cl-reex.operator.first
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed)
  (:import-from :cl-reex.observable
        :observable
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :dispose
        :get-on-next
        :set-on-next
        :get-on-error
        :set-on-error
        :get-on-completed
        :set-on-completed
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-zero-arg-or-function-like-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:import-from :cl-reex.error-conditions
        :sequence-contains-no-elements-error )
  (:export :operator-first
        :first
        :make-operator-first ))

(in-package :cl-reex.operator.first)


(defclass operator-first (operator)
  ((predicate :initarg :predicate
              :initform nil
              :accessor predicate ))
  (:documentation "First operator"))

(defun make-operator-first (observable &optional predicate)
  (if (not (null predicate))
      ;; has predicate
      (let ((op (make-instance 'operator-first
                               :observable observable
                               :predicate predicate )))
        (set-on-next
         #'(lambda (x)
             (when (and (is-active op)
                        (funcall (predicate op) x) )
               (set-completed op)
               (funcall (get-on-next (observer op)) x)
               (funcall (get-on-completed (observer op))) ))
         op )
        (set-on-error
         #'(lambda (x)
             (when (is-active op)
               (set-error op)
               (funcall (get-on-error (observer op)) x) ))
         op )
        (set-on-completed
         #'(lambda ()
             (when (is-active op)
               (set-error op)
               (let ((err (make-instance 'sequence-contains-no-elements-error)))
                 (funcall (get-on-error (observer op)) err) )))
         op )
        op )

      ;; no predicate
      (let ((op (make-instance 'operator-first
                               :observable observable )))
        (set-on-next
         #'(lambda (x)
             (when (is-active op)
               (funcall (get-on-next (observer op)) x)
               (set-completed op)
               (funcall (get-on-completed (observer op))) ))
         op )
        (set-on-error
         #'(lambda (x)
             (when (is-active op)
               (set-error op)
               (funcall (get-on-error (observer op)) x) ))
         op )
        (set-on-completed
         #'(lambda ()
             (when (is-active op)
               (set-error op)
               (let ((err (make-condition 'sequence-contains-no-elements-error)))
                 (funcall (get-on-error (observer op)) err) )))
         op )
        op )))
  

(set-zero-arg-or-function-like-operator 'first 'make-operator-first)

