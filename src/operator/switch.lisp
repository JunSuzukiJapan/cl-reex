(in-package :cl-user)
(defpackage cl-reex.operator.switch
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :on-next
        :on-error
        :on-completed
        :set-on-next
        :set-on-error
        :set-on-completed )
  (:import-from :cl-reex.observable
        :observable
        :dispose
        :is-active
        :is-completed
        :is-disposed
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:import-from :cl-reex.queue
        :queue
        :make-queue
        :enqueue
        :dequeue
        :is-empty
        :elements-count
        :size )
  (:import-from :cl-reex.macro.operator-table
        :set-zero-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :cleanup-operator
        :subscription )
  (:export :operator-switch
        :switch
        :make-operator-switch ))

(in-package :cl-reex.operator.switch)


(defclass operator-switch (operator)
  ((child-subscription-table :initarg :child-table
                             :initform (make-hash-table)
                             :accessor child-table )
   (latest :initarg :latest
           :initform nil
           :accessor latest )



   (gate :initarg :gate
         :initform (bt:make-lock)
         :accessor gate )
   (busy :initarg :busy
         :initform nil
         :accessor busy )
   ))


(defun make-operator-switch (observable)
  (make-instance 'operator-switch
                 :observable observable ))

(defmethod cleanup-operator ((op operator-switch))
  (set-disposed op)
  (let ((latest (latest op)))
    (when (not (null latest))
      (multiple-value-bind (sub exists)
          (gethash latest (child-table op))
        (when exists
          (dispose sub) ))))
  (call-next-method) )


(defmethod on-next ((op operator-switch) observable)
  (when (is-active op)
    (let ((gate (gate op)))
      (bt:with-lock-held (gate)
        (let* ((observer (make-observer
                          (on-next (x)
                                   (let ((gate (gate op)))
                                     (bt:with-lock-held (gate)
                                       (when (or (is-active op)
                                                 (is-completed op) )
                                         (if (null (latest op))
                                             (setf (latest op) observable)
                                             (let ((latest (latest op))
                                                   (tbl (child-table op)) )
                                               (when (not (eq observable latest))
                                                 (multiple-value-bind (sub exists)
                                                     (gethash latest tbl)
                                                   (when exists
                                                     (dispose sub)
                                                     (remhash latest tbl) )
                                                   (setf (latest op) observable) ))))
                                         (on-next (observer op) x) ))))
                          (on-error (x)
                                    (when (is-active op)
                                      (set-error op)
                                      (on-error (observer op) x) ))
                          (on-completed ()
                                        (when (is-active op)
                                          (when (eq (latest op) observable)
                                            (on-completed (observer op)) )))))
               (sub (subscribe observable observer)))
          (setf (gethash observable (child-table op)) sub) )))))

(defmethod on-error ((op operator-switch) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-switch))
  (when (is-active op)
    (set-completed op) ))


(set-zero-arg-operator 'switch 'make-operator-switch)

