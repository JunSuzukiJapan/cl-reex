(in-package :cl-user)
(defpackage cl-reex.operator.take-until
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed)
  (:import-from :cl-reex.observable
        :observable
        :observable-object
        :is-active
        :set-error
        :set-completed
        :set-disposed
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
  (:export :operator-take-until
        :take-until
        :make-operator-take-until))

(in-package :cl-reex.operator.take-until)


(defclass operator-take-until (operator observable-object)
  ((trigger-observable :initarg :trigger-observable
                       :accessor trigger-observable )
   (triggered :initarg :triggered
              :initform nil
              :accessor triggered ))
  (:documentation "Take-Until operator"))

(defun make-operator-take-until (observable trigger-observable)
  (let ((op (make-instance 'operator-take-until
               :observable observable
               :trigger-observable trigger-observable )))
    (set-on-next
      #'(lambda (x)
          (when (and (not (triggered op))
                     (is-active op) )
            (funcall (get-on-next (observer op)) x) ))
      op )
    (set-on-error
      #'(lambda (x)
          (set-error op)
          (funcall (get-on-error (observer op)) x) )
      op )
    (set-on-completed
      #'(lambda ()
          (set-completed op)
          (funcall (get-on-completed (observer op))) )
      op )

    (set-on-next
      #'(lambda (x)
          (setf (triggered op) t)
          (funcall (get-on-completed (observer op))) )
      trigger-observable )
    (set-on-error
      #'(lambda (x)
          (set-error op)
          (funcall (get-on-error (observer op)) x) )
      trigger-observable )
    (set-on-completed
      #'(lambda () )
      trigger-observable )
    
    op ))

(set-one-arg-operator 'take-until 'make-operator-take-until)

