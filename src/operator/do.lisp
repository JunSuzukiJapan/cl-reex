(in-package :cl-user)
(defpackage cl-reex.operator.do
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
        :set-on-next-error-completed-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-do
        :do
        :make-operator-do))

(in-package :cl-reex.operator.do)


(defclass operator-do (operator)
  ((on-next :initarg :on-next
            :reader get-on-next )
   (on-error :initarg :on-error
             :reader get-on-error )
   (on-completed :initarg :on-completed
                 :reader get-on-completed ))
  (:documentation "Do operator"))

(defun make-operator-do (observable &key on-next on-error on-completed)
  (make-instance 'operator-do
                 :observable observable
                 :on-next on-next
                 :on-error on-error
                 :on-completed on-completed ))


(defmethod on-next ((op operator-do) x)
  (when (is-active op)
    (let ((f (get-on-next op)))
      (when (not (null f))
        (funcall (get-on-next op) x) ))
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-do) x)
  (when (is-active op)
    (set-error op)
    (let ((f (get-on-error op)))
      (when (not (null f))
        (funcall (get-on-error op) x) ))
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-do))
  (when (is-active op)
    (set-completed op)
    (let ((f (get-on-completed op)))
      (when (not (null f))
        (funcall (get-on-completed op)) ))
    (on-completed (observer op)) ))

(set-on-next-error-completed-operator 'do 'make-operator-do)

