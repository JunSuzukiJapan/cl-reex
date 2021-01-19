(in-package :cl-user)
(defpackage cl-reex.operator.contains
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
        :set-one-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-contains
        :contains
        :make-operator-contains))

(in-package :cl-reex.operator.contains)


(defclass operator-contains (operator)
  ((item :initarg :item
         :accessor item ))
  (:documentation "Contains operator"))

(defun make-operator-contains (observable item)
  (make-instance 'operator-contains
                 :observable observable
                 :item item ))


(defmethod on-next ((op operator-contains) x)
  (when (and (is-active op)
             (eq (item op) x) )
    (on-next (observer op) t)
    (set-completed op)
    (on-completed (observer op)) ))

(defmethod on-error ((op operator-contains) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-contains))
  (when (is-active op)
    (on-next (observer op) nil)
    (set-completed op)
    (on-completed (observer op)) ))

(set-one-arg-operator 'contains 'make-operator-contains)

