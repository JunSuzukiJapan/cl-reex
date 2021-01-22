(in-package :cl-user)
(defpackage cl-reex.operator.select
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
        :predicate
        :func)
  (:export :operator-select
        :select
        :make-operator-select))

(in-package :cl-reex.operator.select)


(defclass operator-select (operator)
  ((func :initarg :func
         :accessor func) )
  (:documentation "Select operator"))

(defun make-operator-select (observable func)
  (make-instance 'operator-select
                 :observable observable
                 :func func ))


(defmethod on-next ((op operator-select) x)
  (when (is-active op)
    (let((temp (funcall (func op) x)))
      (on-next (observer op) temp) )))

(defmethod on-error((op operator-select) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-select))
  (when (is-active op)
    (on-completed (observer op))
    (set-completed op) ))

(set-function-like-operator 'select 'make-operator-select)

