(in-package :cl-user)
(defpackage cl-reex.operator.element-at
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
  (:import-from :cl-reex.error-conditions
        :argument-out-of-range-exception )
  (:export :operator-element-at
        :element-at
        :make-operator-element-at ))

(in-package :cl-reex.operator.element-at)


(defclass operator-element-at (operator)
  ((count :initarg :count
          :accessor count-num)
   (current-count :initarg :current-count
                  :initform 0
                  :accessor current-count) )
  (:documentation "Element-At operator"))

(defun make-operator-element-at (observable count)
  (let ((op (make-instance 'operator-element-at
                           :observable observable
                           :count count )))
    (set-on-next
      #'(lambda (x)
          (when (is-active op)
            (incf (current-count op))
            (when (> (current-count op) (count-num op))
              (funcall (get-on-next (observer op)) x)
              (set-completed op)
              (funcall (get-on-completed (observer op))) )))
      op )
    (set-on-error
      #'(lambda (x)
          (when (is-active op)
            (set-error op)
            (funcall (get-on-error (observer op)) x) ))
      op )
    (set-on-completed
      #'(lambda ()
          (when (is-active op)
            (set-error op)
            (let ((err (make-condition 'argument-out-of-range-exception)))
              (funcall (get-on-error (observer op)) err) )))
      op )
    op ))


(defmethod subscribe ((op operator-element-at) observer)
    (setf (current-count op) 0)
    (call-next-method) )

(set-one-arg-operator 'element-at 'make-operator-element-at)

