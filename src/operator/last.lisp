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
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :dispose
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-zero-arg-or-function-like-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:import-from :cl-reex.error-conditions
        :sequence-contains-no-elements-error )
  (:export :operator-last
        :last
        :make-operator-last ))

(in-package :cl-reex.operator.last)


(defclass operator-last (operator)
  ((predicate :initarg :predicate
              :accessor predicate )
   (last-item :initarg :last-item
              :accessor last-item )
   (has-last-item :initarg :has-last-item
                  :initform nil
                  :accessor has-last-item ))
  (:documentation "Last operator"))

(defun make-operator-last (observable &optional predicate)
  (if (null predicate)
      (make-instance 'operator-last
                     :observable observable )
      (make-instance 'operator-last
                     :observable observable
                     :predicate predicate )))


(defmethod on-next ((op operator-last) x)
  (when (is-active op)
    (if (slot-boundp op 'predicate)
        (when (funcall (predicate op) x)
          (setf (last-item op) x)
          (setf (has-last-item op) t) )
        (progn
          (setf (last-item op) x)
          (setf (has-last-item op) t)))))

(defmethod on-error ((op operator-last) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-last))
  (when (is-active op)
    (if (has-last-item op)
        (progn
          (on-next (observer op) (last-item op))
          (set-completed op)
          (on-completed (observer op)) )
        (progn
          (set-error op)
          (let ((err (make-condition 'sequence-contains-no-elements-error)))
            (on-error (observer op) err) )))))
  
(defmethod subscribe ((op operator-last) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (has-last-item op) nil)
    (call-next-method) ))

(set-zero-arg-or-function-like-operator 'last 'make-operator-last)

