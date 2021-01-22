(in-package :cl-user)
(defpackage cl-reex.operator.distinct
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
        :operator )
  (:export :operator-distinct
        :distinct
        :distinct-until-changed
        :make-operator-distinct))

(in-package :cl-reex.operator.distinct)


(defclass operator-distinct (operator)
  ((table :initarg :table
          :initform (make-hash-table)
          :accessor table )
   (compare :initarg :compare
            :initform nil
            :accessor compare ))
  (:documentation "Distinct operator"))

(defun make-operator-distinct (observable)
  (make-instance 'operator-distinct
                 :observable observable ))

(defmethod on-next ((op operator-distinct) x)
  (when (is-active op)
    (let ((table (table op)))
      (when (not (nth-value 1 (gethash x table)))
        (setf (gethash x table) x)
        (on-next (observer op) x) ))))

(defmethod on-error ((op operator-distinct) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-distinct))
  (when (is-active op)
    (on-completed (observer op))
    (set-completed op) ))


(set-zero-arg-operator 'distinct 'make-operator-distinct)
(set-zero-arg-operator 'distinct-until-changed 'make-operator-distinct)

