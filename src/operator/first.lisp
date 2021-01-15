(in-package :cl-user)
(defpackage cl-reex.operator.first
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
        :set-zero-arg-or-function-like-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:import-from :cl-reex.error-conditions
        :sequence-contains-no-elements-error )
  (:export :operator-first
        :first
        :make-operator-first ))

(in-package :cl-reex.operator.first)


(defclass operator-first (operator)
  ((predicate :initarg :predicate
              :accessor predicate ))
  (:documentation "First operator"))

(defun make-operator-first (observable &optional predicate)
  (if (null predicate)
      (make-instance 'operator-first
                     :observable observable )
      (make-instance 'operator-first
                     :observable observable
                     :predicate predicate )))


(defmethod on-next ((op operator-first) x)
  (when (is-active op)
    (if (slot-boundp op 'predicate)
      (when (funcall (predicate op) x)
        (set-completed op)
        (on-next (observer op) x)
        (on-completed (observer op)) )
      (progn
        (on-next (observer op) x)
        (set-completed op)
        (on-completed (observer op)) ))))

(defmethod on-error ((op operator-first) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-first))
  (when (is-active op)
    (set-error op)
    (let ((err (make-condition 'sequence-contains-no-elements-error)))
      (on-error (observer op) err) )))


(set-zero-arg-or-function-like-operator 'first 'make-operator-first)

