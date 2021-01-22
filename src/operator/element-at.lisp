(in-package :cl-user)
(defpackage cl-reex.operator.element-at
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
        :set-one-arg-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:import-from :cl-reex.error-conditions
        :argument-out-of-range-exception )
  (:export :operator-element-at
        :element-at
        :make-operator-element-at ))

(in-package :cl-reex.operator.element-at)


(defclass operator-element-at (operator)
  ((count :initarg :count
          :accessor count-num)
   (current-count :initarg :current-count
                  :initform 0
                  :accessor current-count) )
  (:documentation "Element-At operator"))

(defun make-operator-element-at (observable count)
  (make-instance 'operator-element-at
                 :observable observable
                 :count count ))

(defmethod on-next ((op operator-element-at) x)
  (when (is-active op)
    (incf (current-count op))
    (when (> (current-count op) (count-num op))
      (on-next (observer op) x)
      (on-completed (observer op))
      (set-completed op) )))

(defmethod on-error ((op operator-element-at) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-element-at))
  (when (is-active op)
    (let ((err (make-condition 'argument-out-of-range-exception)))
      (on-error (observer op) err) )
    (set-error op) ))


(defmethod subscribe ((op operator-element-at) observer)
  (declare (ignore observer))
  (setf (current-count op) 0)
  (call-next-method) )

(set-one-arg-operator 'element-at 'make-operator-element-at)

