(in-package :cl-user)
(defpackage cl-reex.subject.async-subject
  (:use :cl)
  (:import-from :cl-reex.observer
        :on-next
        :on-error
        :on-completed
        :observer)
  (:import-from :cl-reex.observable
        :observable
        :observable-object
        :is-active
        :observable-state
        :state
        :active
        :error
        :completed
        :set-error
        :set-completed
        :set-disposed
        :disposed
        :subscribe
        :dispose)
  (:import-from :cl-reex.subject.subject
        :subject
        :make-subject
        :observers
        :disposable-subject )
  (:export :async-subject
        :make-async-subject ))

(in-package :cl-reex.subject.async-subject)

(defclass async-subject (subject)
  ((current-item :initarg :current-item
                 :accessor current-item )
   (error-item :initarg :error-item
               :accessor error-item )))

(defun make-async-subject ()
  (make-instance 'async-subject))

#|
  (let ((sub (make-instance 'async-subject)))
    (set-on-next
      #'(lambda (x)
          (when (is-active sub)
            (setf (current-item sub) x) ))
      sub )
    (set-on-error
      #'(lambda (x)
          (when (is-active sub)
            (set-error sub)
            (setf (error-item sub) x)
            (dolist (observer (observers sub))
              (funcall (get-on-error observer) x) )))
      sub )
    (set-on-completed
      #'(lambda ()
          (when (is-active sub)
            (set-completed sub)
            (when (slot-boundp sub 'current-item)
              (let ((item (current-item sub)))
                (dolist (observer (observers sub))
                  (funcall (get-on-next observer) item) )))
            (dolist (observer (observers sub))
              (funcall (get-on-completed observer)) )))
      sub )
    sub ))
|#

(defmethod on-next ((sub async-subject) x )
  (when (is-active sub)
    (setf (current-item sub) x) ))

(defmethod on-error ((sub async-subject) x)
  (when (is-active sub)
    (set-error sub)
    (setf (error-item sub) x)
    (dolist (observer (observers sub))
      (on-error observer x) )))

(defmethod on-completed ((sub async-subject))
  (when (is-active sub)
    (set-completed sub)
    (when (slot-boundp sub 'current-item)
      (let ((item (current-item sub)))
        (dolist (observer (observers sub))
          (on-next observer item) )))
    (dolist (observer (observers sub))
      (on-completed observer) )))


;;
;; Subscribe
;;
(defmethod subscribe ((sub async-subject) observer)
  (case (state sub)
    ((error)  (on-error observer (error-item sub)) )
    ((completed)
     (when (slot-boundp sub 'current-item)
       (on-next observer (current-item sub)) )
     (on-completed observer) )
    (t (call-next-method) )))

