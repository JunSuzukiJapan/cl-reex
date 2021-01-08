(in-package :cl-user)
(defpackage cl-reex.operator.take-last
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
        :set-function-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-take-last
        :take-last
        :make-operator-take-last))

(in-package :cl-reex.operator.take-last)


(defclass operator-take-last (operator)
  ((predicate :initarg :predicate
          :accessor predicate )
   (completed :initarg :completed
          :initform nil
          :accessor completed ))
  (:documentation "Take-Last operator"))

(defun make-operator-take-last (observable predicate)
  (let ((op (make-instance 'operator-take-last
         :observable observable
         :predicate predicate )))
    (set-on-next
      #'(lambda (x)
          (when (not (completed op))
            (if (funcall (predicate op) x)
                (funcall (get-on-next (observer op)) x)
                (progn
                  (setf (completed op) t)
                  (funcall (get-on-completed (observer op))) ))))
      op )
    (set-on-error
      #'(lambda (x)
          (funcall (get-on-error (observer op)) x) )
      op )
    (set-on-completed
      #'(lambda () ) ;; do nothing
      op )
    op ))


(defmethod subscribe ((op operator-take-last) observer)
  (setf (completed op) nil)
  (call-next-method) )

(set-function-operator 'take-last 'make-operator-take-last)

