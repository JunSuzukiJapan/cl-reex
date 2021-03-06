(in-package :cl-user)
(defpackage cl-reex.observable
  (:use :cl)
  (:import-from :cl-reex.observer
        :make-observer
        :on-next
        :on-error
        :on-completed )
  (:export :subscribe
        :observable
        :observable-object
        :is-observable
        :is-active
        :is-error
        :is-completed
        :is-disposed
        :observable-state
        :state
        :active
        :error
        :completed
        :set-active
        :set-error
        :set-completed
        :set-disposed
        :disposed
        :observable-from
        :observable-state
        :observable-range
        :observable-just
        :observable-repeat
        :observable-of
        :observable-empty
        :observable-never
        :observable-throw
        :foreach
        :observable-timer
        :observable-interval
        :disposable-do-nothing
        :dispose ))

(in-package :cl-reex.observable)

;; Generic methods

(defgeneric subscribe (observable observer))
(defgeneric observable-from (source))
(defgeneric dispose (obj))

(deftype observable-state ()
  '(member active error completed) )

;;
;; Util
;;
(defclass disposable-do-nothing ()
  ((observable :initarg :observable
               :accessor observable)
   (observer :initarg :observer
             :accessor observer) ))

(defmethod dispose ((observable disposable-do-nothing)))

(defgeneric foreach (observable action))

(defmethod foreach (observable action)
  (let ((observer (make-observer
        (on-next (x) (funcall action x))
        (on-error (x) (declare (ignore x))) ;; do nothing?
        (on-completed () ) )))
    (subscribe observable observer) ))

;;
;;
;;
(defclass observable-object ()
  ((state :initarg :state
          :initform 'active
          :accessor state )
   (disposedp :initarg :disposedp
              :initform nil
              :accessor disposedp )))

(defgeneric is-observable (obj))
(defmethod is-observable (obj) nil)

(defmethod is-observable ((obj observable-object))
  (declare (ignore obj))
  t )

(defgeneric is-active (obj))
(defgeneric is-error (obj))
(defgeneric is-completed (obj))
(defgeneric is-disposed (obj))

(defmethod is-active ((obj observable-object))
  (eq (state obj) 'active) )

(defmethod is-error ((obj observable-object))
  (eq (state obj) 'error) )

(defmethod is-completed ((obj observable-object))
  (eq (state obj) 'completed) )

(defmethod is-disposed ((obj observable-object))
  (disposedp obj) )

(defmethod set-active ((obj observable-object))
  (setf (state obj) 'active) )

(defmethod set-error ((obj observable-object))
  (setf (state obj) 'error) )

(defmethod set-completed ((obj observable-object))
  (setf (state obj) 'completed) )

(defmethod set-disposed ((obj observable-object))
  (setf (disposedp obj) t) )

;;
;; observable-timer
;;
(defclass observable-timer-object ()
  ((start :initarg :start
          :accessor start)
   (interval :initarg :interval
             :initform nil
             :accessor interval )))

(defclass disposable-timer ()
  ((start :initarg :start
          :accessor start)
   (interval :initarg :interval
             :accessor interval )
   (observer :initarg :observer
             :accessor observer )
   (thread :initarg :thread
           :accessor thread )
   (count :initarg :count
          :initform 0
          :accessor count-num )
   (end-p :initarg :end-p
          :initform nil
          :accessor end-p )))

(defmethod is-observable ((obj observable-timer-object))
  (declare (ignore obj))
  t )

(defmethod call-on-next ((dt disposable-timer))
  (let ((num (count-num dt)))
    (bt:make-thread (lambda ()
                    (on-next (observer dt) num) )))
  (incf (count-num dt)) )

(defmethod dispose ((dt disposable-timer))
  (setf (interval dt) nil)
  (setf (end-p dt) t)
  (let ((thread (thread dt)))
    (when (and (not (null thread))
               (bt:thread-alive-p thread) )
      (when (not (eq thread (bt:current-thread)))
        (bt:destroy-thread (thread dt)) )))
  (setf (thread dt) nil) )

(defmethod end-loop-p ((dt disposable-timer))
  (or (end-p dt)
      (null (interval dt)) ))

(defun observable-timer (start &optional interval)
  (make-instance 'observable-timer-object
         :start start
         :interval interval ))

(defun observable-interval (interval)
  (make-instance 'observable-timer-object
         :start interval
         :interval interval ))

(defmethod subscribe ((timer observable-timer-object) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-timer
                              :observer observer
                              :start (start timer)
                              :interval (interval timer)
                              :count 0 )))))
    (let* ((start (start timer))
           (interval (interval timer))
           (dt (make-instance 'disposable-timer
                              :observer observer
                              :start start
                              :interval interval
                              :count 0 ))
           (thread (bt:make-thread
                    (lambda ()
                      (sleep start)
                      (call-on-next dt)
                      (do ((interval (interval dt)))
                          ((or (null interval)
                               (end-loop-p dt) )
                           (on-completed (observer dt)) )
                        (sleep interval)
                        (call-on-next dt) )))) )
      (setf (thread dt) thread)
      dt )))

;;
;; observable empty
;;
(defclass observable-empty-object () nil)

(defmethod is-observable ((obj observable-empty-object))
  (declare (ignore obj))
  t )

(defmethod subscribe ((empty observable-empty-object) observer)
  (on-completed observer)
  (make-instance 'disposable-do-nothing
         :observable empty
         :observer observer ))

(defun observable-empty ()
  (make-instance 'observable-empty-object) )

;;
;; observable never
;;
(defclass observable-never-object () nil)

(defmethod is-observable ((obj observable-never-object))
  (declare (ignore obj))
  t )

(defmethod subscribe ((obj observable-never-object) observer)
  (make-instance 'disposable-do-nothing
         :observable obj
         :observer observer ))

(defun observable-never ()
  (make-instance 'observable-never-object) )

;;
;; observable-throw
;;
(defclass observable-throw-object ()
  ((error-obj :initarg :error-obj
              :accessor error-obj )))

(defmethod is-observable ((obj observable-throw-object))
  (declare (ignore obj))
  t )

(defun observable-throw (err-obj)
  (make-instance 'observable-throw-object
                 :error-obj err-obj ))

(defmethod subscribe ((obj observable-throw-object) observer)
  (on-error observer (error-obj obj))
  (make-instance 'disposable-do-nothing
                 :observable obj
                 :observer observer ))

;;
;; observable from list
;;
(defclass observable-list ()
  ((src-list :initarg :src-list
             :initform nil
             :accessor src-list) )
  (:documentation "Observable from List") )

(defmethod is-observable ((obj observable-list))
  (declare (ignore obj))
  t )

(defmethod subscribe ((lst observable-list) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable lst
                                   :observer observer )))))
    (dolist (x (src-list lst))
      (on-next observer x) )
    (on-completed observer)
    (make-instance 'disposable-do-nothing
                   :observable lst
                   :observer observer )))

(defmethod observable-from ((source list))
  (make-instance 'observable-list :src-list source))

(defun observable-of (&rest body)
  (make-instance 'observable-list :src-list body) )

;;
;; observable from string
;;
(defclass observable-string ()
  ((source :initarg :source
           :accessor source)))

(defmethod is-observable ((obj observable-string))
  (declare (ignore obj))
  t )

(defmethod subscribe ((stream observable-string) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable stream
                                   :observer observer )))))
    (let ((s (make-string-input-stream (source stream))))
      (do ((ch (read-char s nil) (read-char s nil)))
          ((null ch))
        (on-next observer ch) ))
    (on-completed observer)
    (make-instance 'disposable-do-nothing
                   :observable stream
                   :observer observer )))

(defmethod observable-from ((source string))
  (make-instance 'observable-string :source source) )


;;
;; observable from array
;;
(defclass observable-array ()
  ((source :initarg :source
           :initform #()
           :accessor source)) )

(defmethod is-observable ((obj observable-array))
  (declare (ignore obj))
  t )

(defmethod subscribe ((ary observable-array) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable ary
                                   :observer observer )))))
    (loop for item across (source ary)
          do (on-next observer item) )
    (on-completed observer)
    (make-instance 'disposable-do-nothing
                   :observable ary
                   :observer observer )))

(defmethod observable-from ((source array))
  (make-instance 'observable-array :source source) )

;;
;; observable from stream
;;
(defclass observable-stream ()
  ((source :initarg :source
           :accessor source)) )

(defmethod is-observable ((obj observable-stream))
  (declare (ignore obj))
  t )
  
(defmethod subscribe ((stream observable-stream) observer)
  (handler-bind
         ((error (lambda (condition)
              (on-error observer condition)
              (return-from subscribe
                (make-instance 'disposable-do-nothing
                               :observable stream
                               :observer observer )))))
    (let ((strm (source stream)))
      (do ((ch (read-char strm nil) (read-char strm nil)))
      ((null ch))
    (on-next observer ch)))
    (on-completed observer)
    (make-instance 'disposable-do-nothing
           :observable stream
           :observer observer )))

(defmethod observable-from ((source stream))
  (make-instance 'observable-stream :source source) )

;;
;; observable range
;;
(defclass observable-range-object ()
  ((from :initarg :from
         :accessor from)
   (count :initarg :count
          :accessor count-num) ))

(defmethod is-observable ((obj observable-range-object))
  (declare (ignore obj))
  t )
  
(defmethod subscribe ((obj observable-range-object) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable obj
                                   :observer observer )))))
    (do ((i 0 (1+ i))
         (from (from obj))
         (count (count-num obj)) )
        ((>= i count))
      (on-next observer (+ from i)) )
    (on-completed observer)
    (make-instance 'disposable-do-nothing
                   :observable obj
                   :observer observer )))

(defun observable-range (from count)
  (make-instance 'observable-range-object
         :from from
         :count count ))

;;
;; observable just
;;
(defclass observable-just-object ()
  ((item :initarg :item
         :accessor item )))

(defmethod is-observable ((obj observable-just-object))
  (declare (ignore obj))
  t )

(defmethod subscribe ((obj observable-just-object) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable obj
                                   :observer observer )))))
    (on-next observer (item obj))
    (on-completed observer)
    (make-instance 'disposable-do-nothing
                   :observable obj
                   :observer observer )))


(defun observable-just (item)
  (make-instance 'observable-just-object
         :item item ))

;;
;; observable repeat
;;
(defclass observable-repeat-object ()
  ((item :initarg :item
         :accessor item )
   (count :initarg :count
          :accessor count-num )))

(defmethod is-observable ((obj observable-repeat-object))
  (declare (ignore obj))
  t )

(defmethod subscribe ((obj observable-repeat-object) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable obj
                                   :observer observer )))))
    (let ((count (count-num obj))
          (item (item obj)) )
      (do ((i 0 (1+ i)))
          ((>= i count))
        (on-next observer item) )
      (on-completed observer)
      (make-instance 'disposable-do-nothing
                     :observable obj
                     :observer observer ))))


(defun observable-repeat (item count)
  (make-instance 'observable-repeat-object
         :item item
         :count count ))
