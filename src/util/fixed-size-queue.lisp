(in-package :cl-user)
(defpackage cl-reex.fixed-size-queue
  (:use :cl)
  (:export :fixed-size-queue
           :make-fixed-size-queue
           :enqueue
           :dequeue
           :is-empty
           :elements-count
           :size ))

(in-package :cl-reex.fixed-size-queue)

(defclass fixed-size-queue ()
  ((head :initarg :head
         :initform 0
         :accessor head )
   (elem-count :initarg :elem-count
               :initform 0
               :accessor elem-count )
   (ary :initarg :ary
        :accessor ary) ))

(defun make-fixed-size-queue (size)
  (make-instance 'fixed-size-queue
                  :ary (make-array size :initial-element nil )))

(defgeneric is-empty (queue))

(defmethod is-empty ((queue fixed-size-queue))
  (eq (elem-count queue) 0) )

(defgeneric size (queue))

(defmethod size ((queue fixed-size-queue))
  (length (ary queue)) )

(defgeneric elements-count (queue))

(defmethod elements-count ((queue fixed-size-queue))
  (elem-count queue) )

(defmethod get-next-index ((queue fixed-size-queue) index)
  (mod (1+ index) (size queue)) )

(defgeneric enqueue (queue item))

(defmethod enqueue ((queue fixed-size-queue) item)
  (let ((index (mod (+ (head queue) (elem-count queue))
                    (size queue) )))
    (setf (aref (ary queue) index) item)

    (if (eq (elem-count queue) (size queue))
        (setf (head queue) (get-next-index queue (head queue)))
        (setf (elem-count queue) (1+ (elem-count queue))) ))
  item )

(defgeneric dequeue (queue))

(defmethod dequeue ((queue fixed-size-queue))
  (when (is-empty queue)
    (error "no item in queue.") )

  (let* ((head (head queue))
         (item (aref (ary queue) head)) )
    (setf (head queue) (get-next-index queue head))
    (setf (elem-count queue) (1- (elem-count queue)))
    item ))
  
