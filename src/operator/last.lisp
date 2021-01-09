(in-package :cl-user)
(defpackage cl-reex.operator.last
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
        :set-zero-arg-or-function-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:import-from :cl-reex.error-conditions
        :sequence-contains-no-elements-error )
  (:export :operator-last
        :last
        :make-operator-last ))

(in-package :cl-reex.operator.last)


(defclass operator-last (operator observable-object)
  ((predicate :initarg :predicate
              :initform nil
              :accessor predicate )
   (last-item :initarg :last-item
              :accessor last-item )
   (has-last-item :initarg :has-last-item
                  :initform nil
                  :accessor has-last-item ))
  (:documentation "Last operator"))

(defun make-operator-last (observable &optional predicate)
  (if (not (null predicate))
      ;; has predicate
      (let ((op (make-instance 'operator-last
                               :observable observable
                               :predicate predicate )))
        (set-on-next
         #'(lambda (x)
             (when (and (is-active op)
                        (funcall (predicate op) x) )
               (setf (last-item op) x)
               (setf (has-last-item op) t) ))
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
               (if (has-last-item op)
                   (progn
                     (set-completed op)
                     (funcall (get-on-next (observer op)) (last-item op))
                     (funcall (get-on-completed (observer op))) )
                   (progn
                     (set-error op)
                     (let ((err (make-condition 'sequence-contains-no-elements-error)))
                       (funcall (get-on-error (observer op)) err) )))))


         op )
        op )

      ;; no predicate
      (let ((op (make-instance 'operator-last
                               :observable observable )))
        (set-on-next
         #'(lambda (x)
             (when (is-active op)
               (setf (last-item op) x)
               (setf (has-last-item op) t)))
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
               (if (has-last-item op)
                   (progn
                     (set-completed op)
                     (funcall (get-on-next (observer op)) (last-item op))
                     (funcall (get-on-completed (observer op))) )
                   (progn
                     (set-error op)
                     (let ((err (make-condition 'sequence-contains-no-elements-error)))
                       (funcall (get-on-error (observer op)) err) )))))
         op )
        op )))
  
(defmethod subscribe ((op operator-last) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (funcall (get-on-error observer) condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (has-last-item op) nil)
    (call-next-method) ))

(set-zero-arg-or-function-operator 'last 'make-operator-last)

