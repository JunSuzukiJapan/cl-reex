(in-package :cl-user)
(defpackage cl-reex.operator.any
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
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-function-like-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-any
        :any
        :make-operator-any))

(in-package :cl-reex.operator.any)


(defclass operator-any (operator)
  ((predicate :initarg :predicate
              :accessor predicate ))
  (:documentation "Any operator"))

(defun make-operator-any (observable predicate)
  (make-instance 'operator-any
                 :observable observable
                 :predicate predicate ))


(defmethod on-next ((op operator-any) x)
  (when (and (is-active op)
             (funcall (predicate op) x) )
    (on-next (observer op) t)
    (on-completed (observer op))
    (set-completed op) ))

(defmethod on-error ((op operator-any) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-any))
  (when (is-active op)
    (on-next (observer op) nil)
    (on-completed (observer op))
    (set-completed op) ))

(set-function-like-operator 'any 'make-operator-any)

