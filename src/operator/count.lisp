(in-package :cl-user)
(defpackage cl-reex.operator.count
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
        :set-zero-arg-or-function-like-operator )
  (:import-from :cl-reex.operator
        :operator )
  (:export :operator-count
        :count
        :make-operator-count ))

(in-package :cl-reex.operator.count)


(defclass operator-count (operator)
  ((count :initarg :count
          :initform 0
          :accessor count-num )
   (predicate :initarg :predicate
              :accessor predicate ))
  (:documentation "Count operator") )

(defun make-operator-count (observable &optional predicate)
  (if (null predicate)
      (make-instance 'operator-count
                     :observable observable )
      (make-instance 'operator-count
                     :observable observable
                     :predicate predicate )))


(defmethod on-next ((op operator-count) x)
  (when (is-active op)
    (if (slot-boundp op 'predicate)
      (when (funcall (predicate op) x)
        (incf (count-num op)) )
      (incf (count-num op)) )))

(defmethod on-error ((op operator-count) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-count))
  (when (is-active op)
    (on-next (observer op) (count-num op))
    (on-completed (observer op))
    (set-completed op) ))

(set-zero-arg-or-function-like-operator 'count 'make-operator-count)

