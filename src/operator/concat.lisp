(in-package :cl-user)
(defpackage cl-reex.operator.concat
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
        :set-rest-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :subscription )
  (:export :operator-concat
        :concat
        :make-operator-concat ))

(in-package :cl-reex.operator.concat)


(defclass operator-concat (operator)
  ((observable-list :initarg :observable-list
                    :accessor observable-list )
   (next-observable :initarg :next-observable
                    :accessor next-observable ))
  (:documentation "Concat operator"))

(defun make-operator-concat (observable &rest observable-list)
  (let ((op (make-instance 'operator-concat
                           :observable observable
                           :observable-list observable-list )))
    (setf (next-observable op) (observable-list op))
    op ))


(defmethod on-next ((op operator-concat) x)
  (when (is-active op)
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-concat) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-concat))
  (when (is-active op)
    (if (null (next-observable op))
        (progn
          (on-completed (observer op))
          (set-completed op) )
        (let ((obs (car (next-observable op))))
          (setf (next-observable op) (cdr (next-observable op)))

          (when (slot-boundp op 'subscription)
            (dispose (subscription op)) )
          (setf (subscription op) (subscribe obs op)) ))))


(defmethod subscribe ((op operator-concat) observer)
  (declare (ignore observer))
  (setf (next-observable op) (observable-list op))
  (call-next-method) )


(set-rest-arg-operator 'concat 'make-operator-concat)

