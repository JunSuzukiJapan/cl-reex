(in-package :cl-user)
(defpackage cl-reex.operator.skip-last
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
  (:export :operator-skip-last
        :skip-last
        :make-operator-skip-last))

(in-package :cl-reex.operator.skip-last)


(defclass operator-skip-last (operator)
  ((skip-count :initarg :skip-count
               :accessor skip-count )
   (stack :initarg :stack
          :initform nil
          :accessor stack ))
  (:documentation "Skip-Last operator"))

(defun make-operator-skip-last (observable count)
  (let* ((op (make-instance 'operator-skip-last
                            :observable observable
                            :skip-count count )))
    (set-on-next
      #'(lambda (x)
          (push x (stack op)) )
      op )
    (set-on-error
      #'(lambda (x)
          (funcall (get-on-error (observer op)) x) )
      op )
    (set-on-completed
      #'(lambda ()
          (let ((on-next (get-on-next (observer op)))
                (observer (observer op))
                (lst (stack op)) )
            ;; skip
            (dotimes (i (skip-count op))
              (pop lst) )
            (dolist (item (nreverse lst))
              (funcall on-next item) ))
          (funcall (get-on-completed (observer op))) )
      op )
    op ))


(set-one-arg-operator 'skip-last 'make-operator-skip-last)

