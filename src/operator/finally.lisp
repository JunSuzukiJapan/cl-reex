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
        :dispose
        :get-on-next
        :set-on-next
        :get-on-error
        :set-on-error
        :get-on-completed
        :set-on-completed
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
  (let ((op (make-instance 'operator-finally
                           :observable observable
                           :action action )))
    (set-on-next
      #'(lambda (x)
          (funcall (get-on-next (observer op)) x) )
      op )
    (set-on-error
      #'(lambda (x)
          (unwind-protect
           (funcall (get-on-error (observer op)) x)
           (funcall action) ))
      op )
    (set-on-completed
      #'(lambda ()
          (unwind-protect
           (funcall (get-on-completed (observer op)))
           (funcall action) ))
      op )
    op ))

(defmethod subscribe ((op operator-finally) observer)
  (handler-bind
      ((condition #'(lambda (condition)
                  (funcall (action op))
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (call-next-method) ))


(set-one-arg-operator 'finally 'make-operator-finally)

