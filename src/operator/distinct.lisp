(in-package :cl-user)
(defpackage cl-reex.operator.distinct
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
        :set-zero-arg-operator)
  (:import-from :cl-reex.operator
        :operator )
  (:export :operator-distinct
        :distinct
        :distinct-until-changed
        :make-operator-distinct))

(in-package :cl-reex.operator.distinct)


(defclass operator-distinct (operator)
  ((table :initarg :table
          :initform (make-hash-table)
          :accessor table )
   (compare :initarg :compare
            :initform nil
            :accessor compare ))
  (:documentation "Distinct operator"))

(defun make-operator-distinct (observable)
  (let ((op (make-instance 'operator-distinct
                           :observable observable )))
    (set-on-next
      #'(lambda (x)
          (let ((table (table op)))
            (when (not (nth-value 1 (gethash x table)))
              (setf (gethash x table) x)
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

(set-zero-arg-operator 'distinct 'make-operator-distinct)
(set-zero-arg-operator 'distinct-until-changed 'make-operator-distinct)

