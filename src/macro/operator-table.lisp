(in-package :cl-user)
(defpackage cl-reex.macro.operator-table
  (:use :cl)
  (:export :set-one-arg-operator
       :set-function-like-operator
       :set-operator-expander
       :get-operator-expander
       :set-zero-arg-operator
       :set-zero-or-one-arg-operator
       :set-zero-arg-or-function-like-operator
       :set-one-or-rest-arg-operator-quote
       :set-on-next-error-completed-operator
       :set-zero-or-one-arg-function-like-operator
       :set-rest-arg-operator ))

(in-package :cl-reex.macro.operator-table)

(defparameter *op-table* (make-hash-table))

(defun get-operator-expander (name)
  (gethash name *op-table*))

(defun set-operator-expander (name op)
  (setf (gethash name *op-table*) op) )


;;
;; in Let*-expr
;;    make definition like below
;;
;; (let* (...
;;        !! from HERE !!
;;        (var-name (rx:make-operator-where
;;                       temp-observable
;;                       #'(lambda (x) (evenp x)) ))
;;        !! to HERE   !!
;;        ...)
;;    ...)
;;

;;
;; set-function-operator
;;   use when expr like (where (x) (+ x 1))  ;; arg1 is params
;;                                           ;; arg2 is a expr
;;
;; set-one-arg-operator
;;   use when expr like (repeat 3)  ;; arg length is 1.
;;
(defun set-function-like-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        `(,var-name
          (,function-name
           ,temp-observable
           #'(lambda ,(cadr x) ,@(cddr x) ))))))

(defun set-zero-or-one-arg-function-like-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        (if (consp (cadr x))
            `(,var-name
              (,function-name
               ,temp-observable
               #'(lambda ,(cadr x) ,@(cddr x) )))
            `(,var-name
              (,function-name
               ,temp-observable
               #'(lambda ,(caddr x) ,@(cdddr x) )
               ,(cadr x) ))))))

(defun set-zero-arg-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        (declare (ignore x))
        `(,var-name
          (,function-name
           ,temp-observable )))))

(defun set-one-arg-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        `(,var-name
          (,function-name
           ,temp-observable
           ,(cadr x) )))))

(defun set-zero-arg-or-function-like-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        (if (null (cdr x))
            `(,var-name
              (,function-name
               ,temp-observable ))
            `(,var-name
              (,function-name
               ,temp-observable
               #'(lambda ,(cadr x) ,@(cddr x) )))))))

(defun set-zero-or-one-arg-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        (if (null x)
            `(,var-name
              (,function-name
               ,temp-observable ))
            `(,var-name
              (,function-name
               ,temp-observable
               ,(cadr x) ))))))

(defun set-one-or-rest-arg-operator-quote (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        (if (null (cddr x))
            `(,var-name
              (,function-name
               ,temp-observable
               ,(cadr x) ))
            `(,var-name
              (,function-name
               ,temp-observable
               ',(cadr x)
               ',(cddr x) ))))))

(defun set-on-next-error-completed-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        `(,var-name
          (,function-name
           ,temp-observable
           ,@(cdr x) )))))
 
(defun set-rest-arg-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
        `(,var-name
          (,function-name
           ,temp-observable
           ,@(cdr x) )))))

