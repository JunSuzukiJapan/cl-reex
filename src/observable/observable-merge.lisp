(in-package :cl-user)
(defpackage cl-reex.observable.merge
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :on-next
        :on-error
        :on-completed )
  (:import-from :cl-reex.observable
        :observable
        :observable-object
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
  (:export :observable-merge) )


(in-package :cl-reex.observable.merge)


(defclass observable-merge-object (observable-object)
  ((observable-observables :initarg :observable-observables
                           :accessor observable-observables )
   (observer :initarg :observer
             :accessor observer )
   (subscription :initarg :subscription
                 :initform nil
                 :accessor subscription )
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

(defclass disposable-observable-merge-object ()
  ((obs-merge :initarg :obs-merge
              :accessor obs-merge )
   (observer :initarg :observer
             :accessor observer )))

(defun make-observable-merge-object (observable-observables)
  (make-instance 'observable-merge-object
                 :observable-observables observable-observables ))

(defun clear-subscription (obj)
  (when (slot-boundp obj 'subscription)
    (let ((sub (subscription obj)))
      (when (not (null sub))
        (dispose sub) ))
    (setf (subscription obj) nil) ))

(defun clear-child-subscription (obj)
  (when (slot-boundp obj 'child-subscription)
    (let ((sub (child-subscription obj)))
      (when (not (null sub))
        (dispose sub) ))
    (setf (child-subscription obj) nil) ))

(defmethod dispose ((dis-merge disposable-observable-merge-object))
  (let ((merge (obs-merge dis-merge)))
    (set-disposed merge)
    (clear-child-subscription merge)
    (clear-subscription merge) ))


(defmethod on-next ((obj observable-merge-object) observable)
  (when (is-active obj)
    (let ((gate (gate obj)))
      (bt:with-lock-held (gate)
        (if (busy obj)
            (progn
              (enqueue (waiting-observables obj) observable)
              (return-from on-next) )
            (setf (busy obj) t) ))

      (clear-child-subscription obj)
      (setf (child-subscription obj)
            (subscribe observable
                       (make-observer
                        (on-next (x) (on-next (observer obj) x))
                        (on-error (x)
                                  (set-error obj)
                                  (on-error (observer obj) x) )
                        (on-completed ()
                                      (if (is-empty (waiting-observables obj))
                                          ;; empty queue
                                          (progn
                                            (bt:with-lock-held (gate)
                                              (setf (busy obj) nil) )
                                            (when (is-completed obj)
                                              (on-completed (observer obj)) ))
                                          ;; not empty
                                          (subscribe-next obj) ))))))))

(defmethod subscribe-next ((obj observable-merge-object))
  (clear-child-subscription obj)
  (let ((next (dequeue (waiting-observables obj))))
    (when (not (null next))
      (setf (child-subscription obj)
            (subscribe next
                       (make-observer
                        (on-next (x) (on-next (observer obj) x))
                        (on-error (x)
                                  (set-error obj)
                                  (on-error (observer obj) x) )
                        (on-completed ()
                                      (if (is-empty (waiting-observables obj))
                                          ;; empty queue
                                          (let ((gate (gate obj)))
                                            (bt:with-lock-held (gate)
                                              (setf (busy obj) nil) )
                                            (when (is-completed obj)
                                              (on-completed (observer obj)) ))
                                          ;; not empty
                                          (subscribe-next obj) ))))))))


(defmethod on-error ((obj observable-merge-object) x)
  (when (is-active obj)
    (on-error (observer obj) x)
    (set-error obj) ))

(defmethod on-completed ((obj observable-merge-object))
  (when (is-active obj)
    (when (is-empty (waiting-observables obj))
      (on-completed (observer obj)) )
    (set-completed obj) ))


(defmethod subscribe ((obj observable-merge-object) observer)
  (setf (observer obj) observer)
  (let ((sub (subscribe (observable-observables obj) obj)))
    (setf (subscription obj) sub)
    (make-instance 'disposable-observable-merge-object
                   :obs-merge obj
                   :observer observer )))


(defun observable-merge (observable-observables)
  (make-observable-merge-object observable-observables) )
