(in-package :cl-user)
(defpackage cl-reex.operator.where
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed )
  (:import-from :cl-reex.observable
        :observable
        :dispose
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:import-from :cl-reex.macro.operator-table
        :set-function-like-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate )
  (:export :operator-where
        :where
        :make-operator-where ))

(in-package :cl-reex.operator.where)


(defclass operator-where (operator)
  ((predicate :initarg :predicate
              :accessor predicate ))
  (:documentation "Where operator") )

(defun make-operator-where (observable predicate)
  (make-instance 'operator-where
                 :observable observable
                 :predicate predicate ))


(defmethod on-next ((op operator-where) x)
  (when (and (is-active op)
             (funcall (predicate op) x) )
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-where) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-where))
  (when (is-active op)
    (set-completed op)
    (on-completed (observer op)) ))

(set-function-like-operator 'where 'make-operator-where)

