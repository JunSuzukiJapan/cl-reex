(in-package :cl-user)
(defpackage cl-reex.observable.amb
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
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:export :observable-amb) )


(in-package :cl-reex.observable.amb)


(defclass observable-amb-object (observable-object)
  ((sources :initarg :sources
            :initform nil
            :accessor sources )
   (fastest :initarg :fastest
            :initform nil
            :accessor fastest )
   (source-subscription-pairs :initarg :pairs
                              :initform nil
                              :accessor pairs )))

(defun make-observable-amb-object (sources)
  (make-instance 'observable-amb-object
                 :sources sources ))

(defmethod clear-pairs-without ((amb observable-amb-object) source)
  (let ((fastest))
    (dolist (pair (pairs amb))
      (if (eq (car pair) source)
          (setf fastest pair)
        (dispose (cdr pair)) ))
    (setf (fastest amb) fastest) )
  (setf (pairs amb) nil) )

(defmethod cleanup ((amb observable-amb-object))
  (clear-pairs-without amb nil)
  (setf (fastest amb) nil) )


(defclass disposable-observable-amb-object ()
  ((amb :initarg :amb
        :accessor amb )
   (observer :initarg :observer
             :accessor observer )))

(defmethod dispose ((dis-amb disposable-observable-amb-object))
  (let ((amb (amb dis-amb)))
    (cleanup amb) ))

(defmethod subscribe ((amb observable-amb-object) observer)
  ;; clear old subscriptions, if exists
  (set-disposed amb)
  (cleanup amb)

  ;; subscribe again
  (dolist (source (sources amb))
    (let* ((observer (make-observer
                      ;; on-next
                      (on-next (x)
                          (when (not (null (pairs amb)))
                            (clear-pairs-without amb source) )
                          (on-next observer x) )
                      ;; on-error
                      (on-error (x)
                          (on-error observer x)
                          (set-error amb) )
                      ;; on-completed
                      (on-completed ()
                          (on-completed observer)
                          (set-completed amb) )))
           (sub (subscribe source observer)) )
      (push (cons source sub) (pairs amb)) ))

  (make-instance 'disposable-observable-amb-object
         :amb amb
         :observer observer ))

(defun observable-amb (&rest sources)
  (make-observable-amb-object sources) )
