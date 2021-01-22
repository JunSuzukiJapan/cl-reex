(in-package :cl-user)
(defpackage cl-reex.operator.ignore-elements
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
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-zero-arg-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-ignore-elements
        :ignore-elements
        :make-operator-ignore-elements))

(in-package :cl-reex.operator.ignore-elements)


(defclass operator-ignore-elements (operator)
  ()
  (:documentation "Ignore-Elements operator"))

(defun make-operator-ignore-elements (observable)
  (make-instance 'operator-ignore-elements
                 :observable observable ))


(defmethod on-next ((op operator-ignore-elements) x )
  (declare (ignore x))
  ;; do nothing
  )

(defmethod on-error ((op operator-ignore-elements) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-ignore-elements))
  (when (is-active op)
    (on-completed (observer op))
    (set-completed op) ))


(set-zero-arg-operator 'ignore-elements 'make-operator-ignore-elements)

