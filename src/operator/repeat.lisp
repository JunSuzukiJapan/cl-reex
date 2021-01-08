(in-package :cl-user)
(defpackage cl-reex.operator.repeat
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
  (:export :operator-repeat
        :repeat
        :make-operator-repeat))

(in-package :cl-reex.operator.repeat)


(defclass operator-repeat (operator)
  ((count :initarg :count
          :accessor count-num)
   (current-count :initarg :current-count
                  :initform 0
                  :accessor current-count) )
  (:documentation "Repeat operator"))

(defun make-operator-repeat (observable count)
  (let ((op (make-instance 'operator-repeat
                           :observable observable
                           :count count )))
    (set-on-next
      #'(lambda (x)
          (funcall (get-on-next (observer op)) x) )
      op )
    (set-on-error
      #'(lambda (x)
          (funcall (get-on-error (observer op)) x) )
      op )
    (set-on-completed
      #'(lambda ()
          (incf (current-count op))
          (if (>= (current-count op) (count-num op))
              (funcall (get-on-completed (observer op)))
              (subscribe (observable op) op) ))
      op )
    op ))

(defmethod subscribe ((op operator-repeat) observer)
  (setf (current-count op) 0)
  (call-next-method) )

(set-one-arg-operator 'repeat 'make-operator-repeat)

