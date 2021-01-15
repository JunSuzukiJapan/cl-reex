(in-package :cl-user)
(defpackage cl-reex.subject.behavior-subject
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
  (:export :behavior-subject
        :make-behavior-subject ))

(in-package :cl-reex.subject.behavior-subject)

(defclass behavior-subject (subject)
  ((current-item :initarg :current-item
                 :accessor current-item )
   (error-item :initarg :error-item
               :accessor error-item )))

(defun make-behavior-subject (item)
  (make-instance 'behavior-subject
                 :current-item item ))

#|
  (let ((sub (make-instance 'behavior-subject
                            :current-item item )))
    (set-on-next
      #'(lambda (x)
          (when (is-active sub)
            (setf (current-item sub) x)
            (dolist (observer (observers sub))
              (funcall (get-on-next observer) x) )))
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
            (dolist (observer (observers sub))
              (funcall (get-on-completed observer)) )))
      sub )
    sub ))
|#


(defmethod on-next ((sub behavior-subject) x)
  (when (is-active sub)
    (setf (current-item sub) x)
    (dolist (observer (observers sub))
      (on-next observer x) )))

(defmethod on-error ((sub behavior-subject) x)
  (when (is-active sub)
    (set-error sub)
    (setf (error-item sub) x)
    (dolist (observer (observers sub))
      (on-error observer x) )))

(defmethod on-completed ((sub behavior-subject))
  (when (is-active sub)
    (set-completed sub)
    (dolist (observer (observers sub))
      (on-completed observer) )))


;;
;; Subscribe
;;
(defmethod subscribe ((sub behavior-subject) observer)
  (case (state sub)
    ((active) (on-next observer (current-item sub)))
    ((error)  (on-next observer (current-item sub))
              (on-error observer (error-item sub)) )
    ((completed) (on-completed observer)) )
  (call-next-method) )

