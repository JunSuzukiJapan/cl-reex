(in-package :cl-user)
(defpackage cl-reex.operator.where
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed)
  (:import-from :cl-reex.observable
        :observable
        :dispose
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :get-on-next
        :set-on-next
        :get-on-error
        :set-on-error
        :get-on-completed
        :set-on-completed
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-function-like-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-where
        :where
        :make-operator-where))

(in-package :cl-reex.operator.where)


(defclass operator-where (operator)
  ((predicate :initarg :predicate
              :accessor predicate ))
  (:documentation "Where operator"))

(defun make-operator-where (observable predicate)
  (let ((op (make-instance 'operator-where
                           :observable observable
                           :predicate predicate )))
    (set-on-next
      #'(lambda (x)
          (when (and (is-active op)
                     (funcall (predicate op) x) )
            (funcall (get-on-next (observer op)) x) ))
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
            (set-completed op)
            (funcall (get-on-completed (observer op))) ))
      op )
    op ))

(set-function-like-operator 'where 'make-operator-where)

