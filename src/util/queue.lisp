(in-package :cl-user)
(defpackage cl-reex.queue
  (:use :cl)
  (:import-from :cl-reex.fixed-size-queue
           :enqueue
           :dequeue
           :is-empty
           :elements-count
           :size )
  (:export :queue
           :make-queue
           :enqueue
           :dequeue
           :is-empty
           :elements-count
           :size ))

(in-package :cl-reex.queue)

(defclass queue ()
  ((items :initarg :items
          :initform nil
          :accessor items )))

(defun make-queue ()
  (make-instance 'queue) )


(defmethod is-empty ((queue queue))
  (null (items queue)) )

(defmethod elements-count ((queue queue))
  (length (items queue)) )

(defmethod enqueue ((queue queue) item)
  (push item (items queue)) )

(defmethod dequeue ((queue queue))
  (when (is-empty queue)
    (error "no item in queue.") )

  (let ((l (items queue))
        (pre-last nil) )
    (do ((value (car l) (car l)))
        ((null (cdr l))
         (if pre-last
             (setf (cdr pre-last) nil)
             (setf (items queue) nil) )
         value )

      (setf pre-last l)
      (setf l (cdr l)) )))
  
