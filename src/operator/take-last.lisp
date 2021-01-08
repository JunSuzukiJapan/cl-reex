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
        :set-one-arg-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:import-from :cl-reex.fixed-size-queue
        :queue
        :make-queue
        :enqueue
        :dequeue
        :is-empty
        :elements-count
        :size )
  (:export :operator-take-last
        :take-last
        :make-operator-take-last))

(in-package :cl-reex.operator.take-last)


(defclass operator-take-last (operator)
  ((queue :initarg :queue
          :accessor queue ))
  (:documentation "Take-Last operator"))

(defun make-operator-take-last (observable count)
  (let* ((queue (make-queue count))
         (op (make-instance 'operator-take-last
                            :observable observable
                            :queue queue )))
    (set-on-next
      #'(lambda (x)
          (enqueue (queue op) x) )
      op )
    (set-on-error
      #'(lambda (x)
          (funcall (get-on-error (observer op)) x) )
      op )
    (set-on-completed
      #'(lambda ()
          (do ((queue (queue op))
               (on-next (get-on-next (observer op))) )
              ((is-empty queue)
               (funcall (get-on-completed (observer op))) )
            (let ((item (dequeue queue)))
              (funcall on-next item) )))
      op )
    op ))


(set-one-arg-operator 'take-last 'make-operator-take-last)

