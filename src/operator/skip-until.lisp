(in-package :cl-user)
(defpackage cl-reex.operator.skip-until
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed)
  (:import-from :cl-reex.observable
        :observable
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
  (:export :operator-skip-until
        :skip-until
        :make-operator-skip-until))

(in-package :cl-reex.operator.skip-until)


(defclass operator-skip-until (operator)
  ((trigger-observable :initarg :trigger-observable
                       :accessor trigger-observable )
   (triggered :initarg :triggered
              :initform nil
              :accessor triggered ))
  (:documentation "Skip-Until operator"))

(defun make-operator-skip-until (observable trigger-observable)
  (let ((op (make-instance 'operator-skip-until
               :observable observable
               :trigger-observable trigger-observable )))
    (set-on-next
      #'(lambda (x)
          (when (and (triggered op)
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
          (declare (ignore x))
          (setf (triggered op) t) )
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

(set-one-arg-operator 'skip-until 'make-operator-skip-until)

