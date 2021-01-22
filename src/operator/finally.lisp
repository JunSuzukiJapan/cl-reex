(in-package :cl-user)
(defpackage cl-reex.operator.finally
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
        :disposable-do-nothing
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-one-arg-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-finally
        :finally
        :make-operator-finally))

(in-package :cl-reex.operator.finally)


(defclass operator-finally (operator)
  ((action :initarg :action
           :accessor action ))
  (:documentation "Finally operator"))

(defun make-operator-finally (observable action)
  (make-instance 'operator-finally
                 :observable observable
                 :action action ))

(defmethod on-next ((op operator-finally) x)
  (when (is-active op)
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-finally) x)
  (when (is-active op)
    (set-error op)
    (unwind-protect
         (on-error (observer op) x)
      (funcall (action op)) )))

(defmethod on-completed ((op operator-finally))
  (when (is-active op)
    (unwind-protect
         (on-completed (observer op))
      (funcall (action op))
    (set-completed op) )))

(defmethod subscribe ((op operator-finally) observer)
  (handler-bind
      ((condition #'(lambda (condition)
                      (declare (ignore condition))
                      (funcall (action op))
                      (return-from subscribe
                        (make-instance 'disposable-do-nothing
                                       :observable op
                                       :observer observer )))))
    (call-next-method) ))


(set-one-arg-operator 'finally 'make-operator-finally)

