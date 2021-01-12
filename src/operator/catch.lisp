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
        :dispose
        :disposable-do-nothing
        :get-on-next
        :set-on-next
        :get-on-error
        :set-on-error
        :get-on-completed
        :set-on-completed
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-one-or-two-arg-operator-quote )
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
                     :initform nil
                     :accessor handle-condition )
   (condition-name :initarg :condition-name
                   :accessor condition-name )
   (next-observable :initarg :next-observable
                    :accessor next-observable ))
  (:documentation "Catch* operator"))

(defun make-operator-catch* (observable arg1 &optional arg2)
  (if (null arg2)
      ;; one arg
      (let ((op (make-instance 'operator-catch*
                               :observable observable
                               :next-observable arg1 )))
        (set-on-next
         #'(lambda (x)
             (funcall (get-on-next (observer op)) x) )
         op )
        (set-on-error
         #'(lambda (x)
             (when (slot-boundp op 'subscription)
               (dispose (subscription op))
               (slot-unbound op subscription) )

             (let* ((sub (make-subject))
                    (subscription (subscribe sub (observer op)))
                    (subscription2 (subscribe (next-observable op) sub)) )))
         op )
        (set-on-completed
         #'(lambda ()
             (funcall (get-on-completed (observer op))) )
         op )
        op )


      ;; two arg
      (let ((op (make-instance 'operator-catch*
                               :observable observable
                               :condition-name (car arg1)
                               :handle-condition (cadr arg1)
                               :next-observable arg2 )))
        (set-on-next
         #'(lambda (x)
             (funcall (get-on-next (observer op)) x) )
         op )
        (set-on-error
         #'(lambda (condition)
             (block exit
               (if (slot-boundp op 'handle-condition)
                   (let ((typ (handle-condition op)))
                     (when (typep condition typ)
                       (when (slot-boundp op 'subscription)
                         (dispose (subscription op))
                         (slot-unbound op subscription) )

                       (let ((f
                               (eval `(lambda (,(condition-name op))
                                  ,(next-observable op) ))))
                         (return-from exit
                           (let* ((obs (funcall f condition))
                                  (subsc (subscribe obs (observer op))) )
                             (make-instance 'disposable-do-nothing
                                            :observable obs
                                            :observer observer )))))))))
         op )
        (set-on-completed
         #'(lambda ()
             (funcall (get-on-completed (observer op))) )
         op )
        op )))

(defmethod subscribe ((op operator-catch*) observer)
  (handler-bind
      ((serious-condition
         #'(lambda (condition)
             (block exit
               (if (slot-boundp op 'handle-condition)
                   (let ((typ (handle-condition op)))
                     (when (slot-boundp op 'subscription)
                       (dispose (subscription op))
                       (slot-unbound op subscription) )

                     (let ((f
                             (eval `#'(lambda (,(condition-name op))
                                  ,(next-observable op) ))))
                       (return-from exit
                         (let* ((obs (funcall f condition))
                                (subsc (subscribe obs (observer op))) )
                           (make-instance 'disposable-do-nothing
                                          :observable obs
                                          :observer observer )))))
                   ;; not bound slot 'handle-condition
                   (progn
                     (funcall (get-on-error op) condition)
                     (return-from subscribe
                       (make-instance 'disposable-do-nothing
                                      :observable op
                                      :observer observer ))))
               (return-from exit
                 (make-instance 'disposable-do-nothing
                                :observable op
                                :observer observer ))))))
    (call-next-method) ))


(set-one-or-two-arg-operator-quote 'catch* 'make-operator-catch*)

