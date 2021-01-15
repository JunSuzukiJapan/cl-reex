(in-package :cl-user)
(defpackage cl-reex.macro.handmade-observable
  (:use :cl)
  (:import-from :cl-reex.observable
        :subscribe
        :observable
        :observable-object
        :is-active
        :observable-state
        :state
        :active
        :error
        :completed
        :disposed
        :dispose
        :observable-from
        :on-next
        :on-error
        :on-completed
        :disposable-do-nothing)
  (:import-from :cl-reex.observer
        :observer )
  (:export :handmade-observable) )

(in-package :cl-reex.macro.handmade-observable)


(defclass handmade-observable-object (observable-object)
  ((source :initarg :source
           :accessor source) ))

(defmethod subscribe ((observable handmade-observable-object) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable observable
                                   :observer observer )))))
    (dolist (message (source observable))
      (case (car message)
        ;; on-next
        ((on-next)
         (when (is-active observable)
           (on-next observer (cadr message)) ))
        ;; on-error
        ((on-error)
         (when (is-active observable)
           (setf (state observable) 'error)
           (on-error observer (cadr message)) ))
        ;; on-completed
        ((on-completed)
         (when (is-active observable)
           (setf (state observable) 'completed)
           (on-completed observer) ))))
    (make-instance 'disposable-do-nothing
                   :observable observable
                   :observer observer ) ))

(defmacro handmade-observable (&rest body)
  `(make-instance 'handmade-observable-object
                  :source ',body ))
