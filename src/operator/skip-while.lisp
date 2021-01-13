(in-package :cl-user)
(defpackage cl-reex.operator.skip-while
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
        :set-function-like-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-skip-while
        :skip-while
        :make-operator-skip-while))

(in-package :cl-reex.operator.skip-while)


(defclass operator-skip-while (operator)
  ((predicate :initarg :predicate
              :accessor predicate )
   (completed :initarg :completed
              :initform nil
              :accessor completed ))
  (:documentation "Skip-While operator"))

(defun make-operator-skip-while (observable predicate)
  (let ((op (make-instance 'operator-skip-while
                           :observable observable
                           :predicate predicate )))
    (set-on-next
      #'(lambda (x)
          (if (completed op)
              (funcall (get-on-next (observer op)) x)
              (when (not (funcall (predicate op) x))
                (setf (completed op) t)
                (funcall (get-on-next (observer op)) x) )))
      op )
    (set-on-error
      #'(lambda (x)
          (funcall (get-on-error (observer op)) x) )
      op )
    (set-on-completed
      #'(lambda ()
          (funcall (get-on-completed (observer op))) )
      op )
    op ))


(defmethod subscribe ((op operator-skip-while) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (funcall (get-on-error observer) condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (completed op) nil)
    (call-next-method) ))

(set-function-like-operator 'skip-while 'make-operator-skip-while)

