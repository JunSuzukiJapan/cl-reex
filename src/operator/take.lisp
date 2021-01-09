(in-package :cl-user)
(defpackage cl-reex.operator.take
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
  (:export :operator-take
        :take
        :make-operator-take))

(in-package :cl-reex.operator.take)


(defclass operator-take (operator)
  ((count :initarg :count
          :accessor count-num)
   (current-count :initarg :current-count
                  :initform 0
                  :accessor current-count) )
  (:documentation "Take operator"))

(defun make-operator-take (observable count)
  (let ((op (make-instance 'operator-take
                           :observable observable
                           :count count )))
    (set-on-next
      #'(lambda (x)
          (when (< (current-count op) (count-num op))
            (incf (current-count op))
            (funcall (get-on-next (observer op)) x)
            (when (>= (current-count op) (count-num op))
              (funcall (get-on-completed (observer op))) )))
      op )
    (set-on-error
      #'(lambda (x)
          (funcall (get-on-error (observer op)) x) )
      op )
    (set-on-completed
      #'(lambda () ) ;; do nothing
      op )
    op ))


(defmethod subscribe ((op operator-take) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (funcall (get-on-error observer) condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (current-count op) 0)
    (call-next-method) ))

(set-one-arg-operator 'take 'make-operator-take)

