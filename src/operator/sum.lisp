(in-package :cl-user)
(defpackage cl-reex.operator.sum
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
        :set-zero-arg-operator )
  (:import-from :cl-reex.operator
        :operator )
  (:export :operator-sum
        :sum
        :make-operator-sum ))

(in-package :cl-reex.operator.sum)


(defclass operator-sum (operator)
  ((sum :initarg :sum
        :initform 0
        :accessor sum ))
  (:documentation "Sum operator") )

(defun make-operator-sum (observable)
  (make-instance 'operator-sum
                 :observable observable ))


(defmethod on-next ((op operator-sum) x)
  (when (is-active op)
    (setf (sum op) (+ (sum op) x)) ))

(defmethod on-error ((op operator-sum) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-sum))
  (when (is-active op)
    (on-next (observer op) (sum op))
    (on-completed (observer op))
    (set-completed op) ))

(set-zero-arg-operator 'sum 'make-operator-sum)

