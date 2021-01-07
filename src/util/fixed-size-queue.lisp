(in-package :cl-user)
(defpackage cl-reex.fixed-size-queue
  (:use :cl)
  (:export :queue
           :make-queue
           :enqueue
           :dequeue
           :is-empty
           :elements-count
           :size ))

(in-package :cl-reex.fixed-size-queue)

(defclass queue ()
  ((head :initarg :head
         :initform 0
         :accessor head )
   (elem-count :initarg :elem-count
               :initform 0
               :accessor elem-count )
   (ary :initarg :ary
        :accessor ary) ))

(defun make-queue (size)
  (make-instance' queue
                  :ary (make-array size :initial-element nil )))

(defmethod is-empty ((queue queue))
  (eq (elem-count queue) 0) )

(defmethod size ((queue queue))
  (length (ary queue)) )

(defmethod elements-count ((queue queue))
  (elem-count queue) )

(defmethod get-next-index ((queue queue) index)
  (mod (1+ index) (size queue)) )

(defmethod enqueue ((queue queue) item)
  (let ((index (mod (+ (head queue) (elem-count queue))
                    (size queue) )))
    (setf (aref (ary queue) index) item)

    (if (eq (elem-count queue) (size queue))
        (setf (head queue) (get-next-index queue (head queue)))
        (setf (elem-count queue) (1+ (elem-count queue))) ))
  item )

(defmethod dequeue ((queue queue))
  (when (is-empty queue)
    (error "no item in queue.") )

  (let* ((head (head queue))
         (item (aref (ary queue) head)) )
    (setf (head queue) (get-next-index queue head))
    (setf (elem-count queue) (1- (elem-count queue)))
    item ))
  
