(in-package :cl-user)
(defpackage cl-reex.operator.select-many
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
        :set-function-like-operator )
  (:import-from :cl-reex.operator
        :operator
        :cleanup-operator
        :subscription )
  (:export :operator-select-many
        :select-many
        :make-operator-select-many ))

(in-package :cl-reex.operator.select-many)


(defclass operator-select-many (operator)
  ((selector :initarg :selector
             :accessor selector )
   (child-subscription :initarg :child-subscription
                       :initform nil
                       :accessor child-subscription )
   (gate :initarg :gate
         :initform (bt:make-lock)
         :accessor gate )
   (busy :initarg :busy
         :initform nil
         :accessor busy )
   (waiting-observables :initarg :waiting-observables
                        :initform (make-queue)
                        :accessor waiting-observables )))

(defun make-operator-select-many (observable selector)
  (make-instance 'operator-select-many
                 :observable observable
                 :selector selector ))

(defun clear-child-subscription (op)
  (when (slot-boundp op 'child-subscription)
    (let ((sub (child-subscription op)))
      (when (not (null sub))
        (dispose sub) ))
    (setf (child-subscription op) nil) ))

(defmethod cleanup-operator ((op operator-select-many))
  (set-disposed op)
  (clear-child-subscription op)
  (call-next-method) )


(defmethod on-next ((op operator-select-many) x)
  (when (is-active op)
    (let ((observable (funcall (selector op) x))
          (gate (gate op)))
      (bt:with-lock-held (gate)
        (if (busy op)
            (progn
              (enqueue (waiting-observables op) observable)
              (return-from on-next) )
            (setf (busy op) t) ))

      (clear-child-subscription op)
      (setf (child-subscription op)
            (subscribe observable
                       (make-observer
                        (on-next (x) (on-next (observer op) x))
                        (on-error (x)
                                  (set-error op)
                                  (on-error (observer op) x) )
                        (on-completed ()
                                      (if (is-empty (waiting-observables op))
                                          ;; empty queue
                                          (progn
                                            (bt:with-lock-held (gate)
                                              (setf (busy op) nil) )
                                            (when (is-completed op)
                                              (on-completed (observer op)) ))
                                          ;; not empty
                                          (subscribe-next op) ))))))))

(defmethod subscribe-next ((op operator-select-many))
  (clear-child-subscription op)
  (let ((next (dequeue (waiting-observables op))))
    (when (not (null next))
      (setf (child-subscription op)
            (subscribe next
                       (make-observer
                        (on-next (x) (on-next (observer op) x))
                        (on-error (x)
                                  (set-error op)
                                  (on-error (observer op) x) )
                        (on-completed ()
                                      (if (is-empty (waiting-observables op))
                                          ;; empty queue
                                          (let ((gate (gate op)))
                                            (bt:with-lock-held (gate)
                                              (setf (busy op) nil) )
                                            (when (is-completed op)
                                              (on-completed (observer op)) ))
                                          ;; not empty
                                          (subscribe-next op) ))))))))


(defmethod on-error ((op operator-select-many) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-select-many))
  (when (is-active op)
    (when (is-empty (waiting-observables op))
      (on-completed (observer op)) )
    (set-completed op) ))


(set-function-like-operator 'select-many 'make-operator-select-many)

