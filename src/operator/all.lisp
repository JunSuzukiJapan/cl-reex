(in-package :cl-user)
(defpackage cl-reex.operator.all
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
        :set-function-like-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-all
        :all
        :make-operator-all))

(in-package :cl-reex.operator.all)


(defclass operator-all (operator)
  ((predicate :initarg :predicate
              :accessor predicate ))
  (:documentation "All operator"))

(defun make-operator-all (observable predicate)
  (make-instance 'operator-all
                 :observable observable
                 :predicate predicate ))


(defmethod on-next ((op operator-all) x)
  (when (and (is-active op)
             (not (funcall (predicate op) x)) )
    (on-next (observer op) nil)
    (set-completed op)
    (on-completed (observer op)) ))

(defmethod on-error ((op operator-all) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-all))
  (when (is-active op)
    (on-next (observer op) t)
    (set-completed op)
    (on-completed (observer op)) ))

(set-function-like-operator 'all 'make-operator-all)

