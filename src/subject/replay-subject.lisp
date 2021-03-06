(in-package :cl-user)
(defpackage cl-reex.subject.replay-subject
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
  (:export :replay-subject
        :make-replay-subject ))

(in-package :cl-reex.subject.replay-subject)

(defclass replay-subject (subject)
  ((events :initarg :events
           :initform nil
           :accessor events )))

(defun make-replay-subject ()
  (make-instance 'replay-subject))


(defmethod on-next ((sub replay-subject) x)
  (when (is-active sub)
    (push `(on-next ,x) (events sub))
    (dolist (observer (observers sub))
      (on-next observer x) )))

(defmethod on-error ((sub replay-subject) x)
  (when (is-active sub)
    (push `(on-error ,x) (events sub))
    (dolist (observer (observers sub))
      (on-error observer x) )
    (set-error sub) ))

(defmethod on-completed ((sub replay-subject))
  (when (is-active sub)
    (push `(on-completed) (events sub))
    (dolist (observer (observers sub))
      (on-completed observer) )
    (set-completed sub) ))


;;
;; Subscribe
;;
(defmethod subscribe ((sub replay-subject) observer)
  (let ((lst (reverse (events sub))))
    (dolist (item lst)
      (case (car item)
        ((on-next)
         (on-next observer (cadr item)) )
        ((on-error)
         (on-error observer (cadr item)) )
        ((on-completed)
         (on-completed observer) ))))
  (call-next-method) )

