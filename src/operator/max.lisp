(in-package :cl-user)
(defpackage cl-reex.operator.max
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
  (:export :operator-max
        :max
        :make-operator-max ))

(in-package :cl-reex.operator.max)


(defclass operator-max (operator)
  ((max :initarg :max
        :accessor max-num ))
  (:documentation "Max operator") )

(defun make-operator-max (observable)
  (make-instance 'operator-max
                 :observable observable ))


(defmethod on-next ((op operator-max) x)
  (when (is-active op)
    (if (slot-boundp op 'max)
        (when (< (max-num op) x)
          (setf (max-num op) x) )
        (setf (max-num op) x) )))

(defmethod on-error ((op operator-max) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-max))
  (when (is-active op)
    (on-next (observer op) (max-num op))
    (on-completed (observer op))
    (set-completed op) ))

(set-zero-arg-operator 'max 'make-operator-max)

