(in-package :cl-user)
(defpackage cl-reex.operator.catch-star
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
        :disposable-do-nothing
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-one-or-rest-arg-operator-quote )
  (:import-from :cl-reex.operator
        :operator
        :subscription )
  (:import-from :cl-reex.subject.subject
        :subject
        :make-subject )
  (:export :operator-catch*
        :catch*
        :make-operator-catch* ))

(in-package :cl-reex.operator.catch-star)


(defclass operator-catch* (operator)
  ((handle-condition :initarg :handle-condition
                     :accessor handle-condition )
   (condition-name :initarg :condition-name
                   :accessor condition-name )
   (next-observable :initarg :next-observable
                    :accessor next-observable ))
  (:documentation "Catch* operator"))

(defun make-operator-catch* (observable arg1 &rest args)
  (if (null args)
      (make-instance 'operator-catch*
                     :observable observable
                     :next-observable arg1 )
      (make-instance 'operator-catch*
                     :observable observable
                     :condition-name (car arg1)
                     :handle-condition (cadr arg1)
                     :next-observable (car args) )))


(defmethod on-next ((op operator-catch*) x)
  (when (is-active op)
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-catch*) condition)
  (if (slot-boundp op 'handle-condition)
      ;; have handle-condition
      (let ((typ (handle-condition op)))
        (when (typep condition typ)
          (when (slot-boundp op 'subscription)
            (dispose (subscription op))
            (slot-unbound 'operator-catch* op 'subscription) )

          (let ((f
                  (eval `(lambda (,(condition-name op))
                           ,@(next-observable op) ))))
            (return-from on-error
              (let* ((obs (funcall f condition))
                     (subsc (subscribe obs (observer op))) )
                (declare (ignore subsc))
                (make-instance 'disposable-do-nothing
                               :observable obs
                               :observer (observer op) ))))))
      ;; no handle-condition
      (progn
        (when (slot-boundp op 'subscription)
          (dispose (subscription op))
          (slot-unbound 'operator-catch* op 'subscription) )

        (let* ((sub (make-subject))
               (subscription (subscribe sub (observer op)))
               (subscription2 (subscribe (next-observable op) sub)) )
          (declare (ignore subscription))
          subscription2 ))))

(defmethod on-completed ((op operator-catch*))
  (when (is-active op)
    (set-completed op)
    (on-completed (observer op)) ))

      
(defmethod subscribe ((op operator-catch*) observer)
  (handler-bind
      ((serious-condition
         #'(lambda (condition)
             (block exit
               (if (slot-boundp op 'handle-condition)
                   (progn
                     (when (slot-boundp op 'subscription)
                       (dispose (subscription op))
                       (slot-unbound 'operator-catch* op 'subscription) )

                     (let ((f
                             (eval `#'(lambda (,(condition-name op))
                                  ,@(next-observable op) ))))
                       (return-from exit
                         (let* ((obs (funcall f condition))
                                (subsc (subscribe obs (observer op))) )
                           (declare (ignore subsc))
                           (make-instance 'disposable-do-nothing
                                          :observable obs
                                          :observer observer )))))
                   ;; not bound slot 'handle-condition
                   (progn
                     (on-error op condition)
                     (return-from subscribe
                       (make-instance 'disposable-do-nothing
                                      :observable op
                                      :observer observer ))))))))
    (call-next-method) ))


(set-one-or-rest-arg-operator-quote 'catch* 'make-operator-catch*)

