(in-package :cl-user)
(defpackage cl-reex.operator.min
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
  (:export :operator-min
        :min
        :make-operator-min ))

(in-package :cl-reex.operator.min)


(defclass operator-min (operator)
  ((min :initarg :min
        :accessor min-num ))
  (:documentation "Min operator") )

(defun make-operator-min (observable)
  (make-instance 'operator-min
                 :observable observable ))


(defmethod on-next ((op operator-min) x)
  (when (is-active op)
    (if (slot-boundp op 'min)
        (when (< x (min-num op))
          (setf (min-num op) x) )
        (setf (min-num op) x) )))

(defmethod on-error ((op operator-min) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-min))
  (when (is-active op)
    (set-completed op)
    (on-next (observer op) (min-num op))
    (on-completed (observer op)) ))

(set-zero-arg-operator 'min 'make-operator-min)

