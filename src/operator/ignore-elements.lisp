(in-package :cl-user)
(defpackage cl-reex.operator.ignore-elements
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
        :operator
        :predicate)
  (:export :operator-ignore-elements
        :ignore-elements
        :make-operator-ignore-elements))

(in-package :cl-reex.operator.ignore-elements)


(defclass operator-ignore-elements (operator)
  ()
  (:documentation "Ignore-Elements operator"))

(defun make-operator-ignore-elements (observable)
  (let ((op (make-instance 'operator-ignore-elements
                           :observable observable )))
    (set-on-next
      #'(lambda (x) ) ;; do nothing
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

(set-zero-arg-operator 'ignore-elements 'make-operator-ignore-elements)

