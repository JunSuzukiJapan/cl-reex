(in-package :cl-user)
(defpackage cl-reex.operator.take-until
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :on-next
        :on-error
        :on-completed
        :set-on-next
        :set-on-error
        :set-on-completed )
  (:import-from :cl-reex.observable
        :observable
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :dispose
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-one-arg-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-take-until
        :take-until
        :make-operator-take-until))

(in-package :cl-reex.operator.take-until)


(defclass operator-take-until (operator)
  ((trigger-observable :initarg :trigger-observable
                       :accessor trigger-observable )
   (triggered :initarg :triggered
              :initform nil
              :accessor triggered ))
  (:documentation "Take-Until operator"))

(defun make-operator-take-until (observable trigger-observable)
  (let* ((op (make-instance 'operator-take-until
                            :observable observable
                            :trigger-observable trigger-observable ))
         (observer
           (make-observer
            (on-next (x)
                (declare (ignore x))
                (setf (triggered op) t)
                (on-completed (observer op)) )
            (on-error (x)
                (set-error op)
                (on-error (observer op) x) )
            (on-completed () ) )))
    (subscribe trigger-observable observer)
    op ))

(defmethod on-next ((op operator-take-until) x)
  (when (and (not (triggered op))
             (is-active op) )
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-take-until) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-take-until))
  (when (is-active op)
    (on-completed (observer op))
    (set-completed op) ))

(set-one-arg-operator 'take-until 'make-operator-take-until)

