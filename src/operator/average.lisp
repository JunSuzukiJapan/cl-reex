(in-package :cl-user)
(defpackage cl-reex.operator.average
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
        :operator
        :predicate )
  (:export :operator-average
        :average
        :make-operator-average ))

(in-package :cl-reex.operator.average)


(defclass operator-average (operator)
  ((sum :initarg :sum
        :initform 0
        :accessor sum )
   (count :initarg :count
          :initform 0
          :accessor count-num ))
  (:documentation "Average operator") )

(defun make-operator-average (observable)
  (make-instance 'operator-average
                 :observable observable ))

(defmethod on-next ((op operator-average) x)
  (when (is-active op)
    (incf (count-num op))
    (setf (sum op) (+ (sum op) x)) ))

(defmethod on-error ((op operator-average) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-average))
  (when (is-active op)
    (on-next (observer op)
             (/ (sum op) (count-num op)) )
    (on-completed (observer op))
    (set-completed op) ))

(set-zero-arg-operator 'average 'make-operator-average)

