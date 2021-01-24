(in-package :cl-user)
(defpackage cl-reex.operator.sample
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :on-next
        :on-error
        :on-completed )
  (:import-from :cl-reex.observable
        :observable
        :dispose
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:import-from :cl-reex.macro.operator-table
        :set-one-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :subscription
        :disposable-operator )
  (:export :operator-sample
        :sample
        :make-operator-sample ))

(in-package :cl-reex.operator.sample)

;;
;; class operator-sample-interval
;;
(defclass operator-sample-interval (operator)
  ((interval :initarg :interval
             :accessor interval )
   (thread :initarg :thread
           :accessor thread )
   (item :initarg :item
         :accessor item )
   (has-item :initarg :has-item
             :initform nil
             :accessor has-item )
   (gate :initarg :gate
         :initform (bt:make-lock)
         :accessor gate )))

(defun kill-thread (op)
  (when (and (slot-boundp op 'thread)
             (bt:thread-alive-p (thread op)) )
    (bt:destroy-thread (thread op)) ))

(defmethod cleanup-operator ((op operator-sample-interval))
  (kill-thread op) )

(defmethod on-next ((op operator-sample-interval) x)
  (when (is-active op)
    (let ((gate (gate op)))
      (bt:with-lock-held (gate)
        (setf (item op) x)
        (setf (has-item op) t) ))))

(defmethod on-error ((op operator-sample-interval) x)
  (when (is-active op)
    (kill-thread op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-sample-interval))
  (when (is-active op)
    (kill-thread op)
    (on-completed (observer op))
    (set-completed op) ))

(defmethod subscribe ((op operator-sample-interval) observer)
  (setf (has-item op) nil)
  (setf (thread op)
        (bt:make-thread (lambda ()
                          (let ((interval (interval op)))
                            (loop
                              (sleep interval)
                              (let ((gate (gate op)))
                                (bt:with-lock-held (gate)
                                  (when (and (is-active op)
                                             (has-item op) )
                                    (let ((item (item op)))
                                      (setf (has-item op) nil)
                                      (bt:make-thread (lambda ()
                                                        (on-next (observer op) item) )))))))))))
  (call-next-method) )


;;
;; class operator-sample-observable
;;
(defclass operator-sample-observable (operator)
  ((sampler :initarg :sampler
            :accessor sampler )
   (item :initarg :item
         :accessor item )
   (has-item :initarg :has-item
             :initform nil
             :accessor has-item )
   (gate :initarg :gate
         :initform (bt:make-lock)
         :accessor gate )
   (subscription :initarg subscription
                 :accessor subscription )))

(defun dispose-subscription (op)
  (when (slot-boundp op 'subscription)
    (dispose (subscription op))
    (setf (subscription op) nil) ))

(defmethod cleanup-operator ((op operator-sample-observable))
  (dispose-subscription op) )

(defmethod on-next ((op operator-sample-observable) x)
  (when (is-active op)
    (let ((gate (gate op)))
      (bt:with-lock-held (gate)
        (setf (item op) x)
        (setf (has-item op) t) ))))

(defmethod on-error ((op operator-sample-observable) x)
  (when (is-active op)
    (dispose-subscription op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-sample-observable))
  (when (is-active op)
    (dispose-subscription op)
    (on-completed (observer op))
    (set-completed op) ))

(defmethod subscribe ((op operator-sample-observable) observer)
  (when (slot-boundp op 'subscription)
    (dispose-subscription op) )
  (setf (has-item op) nil)
  (let ((sampler-observer (make-observer
                           (on-next (x)
                                    (declare (ignore x))
                                    (let ((gate (gate op)))
                                      (bt:with-lock-held (gate)
                                        (when (and (is-active op)
                                                   (has-item op) )
                                          (let ((item (item op)))
                                            (setf (has-item op) nil)
                                            (bt:make-thread (lambda ()
                                                              (on-next (observer op) item) )))))))
                           (on-error (x)
                                     (when (is-active op)
                                       (on-error (observer op) x)
                                       (set-error op) ))
                           (on-completed ()
                                         (when (is-active op)
                                           (on-completed (observer op))
                                           (set-completed op) )))))
    (setf (subscription op)
          (subscribe (sampler op) sampler-observer) ))

  (call-next-method) )

;;
;; make operator
;;
(defun make-operator-sample (observable arg)
  (if (numberp arg)
      (make-instance 'operator-sample-interval
                     :observable observable
                     :interval arg )
      (make-instance 'operator-sample-observable
                     :observable observable
                     :sampler arg )))

;; set to operator-table
(set-one-arg-operator 'sample 'make-operator-sample)

