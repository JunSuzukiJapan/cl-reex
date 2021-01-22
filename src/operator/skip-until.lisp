(in-package :cl-user)
(defpackage cl-reex.operator.skip-until
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :set-on-next
        :set-on-error
        :set-on-completed
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
        :set-one-arg-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-skip-until
        :skip-until
        :make-operator-skip-until))

(in-package :cl-reex.operator.skip-until)


(defclass operator-skip-until (operator)
  ((trigger-observable :initarg :trigger-observable
                       :accessor trigger-observable )
   (triggered :initarg :triggered
              :initform nil
              :accessor triggered ))
  (:documentation "Skip-Until operator"))

(defun make-operator-skip-until (observable trigger-observable)
  (let* ((op (make-instance 'operator-skip-until
                            :observable observable
                            :trigger-observable trigger-observable ))
         (observer
           (make-observer
            (on-next (x)
                (declare (ignore x))
                (setf (triggered op) t) )
            (on-error (x)
                (on-error (observer op) x)
                (set-error op) )
            (on-completed () ) )))
    (subscribe trigger-observable observer)
    op ))

(defmethod on-next ((op operator-skip-until) x)
  (when (and (triggered op)
             (is-active op) )
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-skip-until) x)
  (on-error (observer op) x)
  (set-error op) )

(defmethod on-completed ((op operator-skip-until))
  (on-completed (observer op))
  (set-completed op) )

(set-one-arg-operator 'skip-until 'make-operator-skip-until)

