(in-package :cl-user)
(defpackage cl-reex.macro
  (:use :cl)
  (:import-from :cl-reex.observable
 		:subscribe
		:dispose
 		:observable-from)
  (:import-from :cl-reex.observer
 		:observer
 		:make-observer
 		:on-next
 		:on-error
 		:on-completed)
  (:import-from :cl-reex.operator
		:observable
		:operator-where
		:make-operator-where)
  (:import-from :cl-reex.macro.symbols
		:where )
  (:import-from :cl-reex.macro.operator-table
		:get-operator
		:set-operator)
  (:export :with-observable) )

(in-package :cl-reex.macro)

(defmacro with-observable (observable &rest body)
  (when (not (null body))
    (let* ((temp-observable (gensym))
	   (lst `((,temp-observable ,observable)))
	   (var-name (gensym)) )
      (dolist (x body)
	(case (car x)
#|	  ;;
	  ;; Where
	  ;;
	  ('where
	   (setq var-name (gensym))
	   ;; (push `(,var-name
	   ;; 	   (make-operator-where
	   ;; 	    ,temp-observable
	   ;; 	    #'(lambda ,(cadr x) ,(caddr x) )))
	   ;; 	 lst )
	   (let* ((op (get-operator :where))
		  (elem (funcall op x var-name temp-observable)) )
	     (push elem lst) )
	   (setq temp-observable var-name) )
|#
	  ;;
	  ;; Subscribe
	  ('subscribe
	   (setq var-name (gensym))
	   (push `(,var-name
		   (subscribe ,temp-observable ,(cadr x)) )
		 lst )
	   (setq temp-observable var-name) )
	  ;;
	  ;; Dispose
	  ;;
	  ('dispose
	   (setq var-name (gensym))
	   (push `(,var-name
		   (dispose ,temp-observable) )
		 lst )
	   (setq temp-observable var-name) )
	  ;;
	  ;; otherwise
	  ;;
	  (t
	   (setq var-name (gensym))
	   (let* ((op (get-operator (car x)))
		  (elem (funcall op x var-name temp-observable)) )
	     (push elem lst) )
	   (setq temp-observable var-name) )
	  ))
      `(let* ,(nreverse lst)
	 ,var-name ))))


#|
(setq body '(
  (where (x) (evenp x))
  (where (x) (eq (mod x 3) 0))
  (subscribe observer) ))
(macroexpand-1 '(rx:with-observable observable
  (rx:where (x) (evenp x))))
|#


#|
(defvar ol (rx:observable-from '(1 2 3 4 5 6 7 8 9 10)))
(defvar observer (rx:make-observer
		#'(lambda (x) (print x))
		#'(lambda (x) (format t "error: ~S" x))
		#'(lambda () (print "completed")) ))
(rx:subscribe ol observer)

(defvar op)
(setq op (rx:make-operator-where ol #'(lambda (x) (evenp x))))
(rx:subscribe op observer)

(defvar op2)
(setq op2 (rx:make-operator-where op #'(lambda (x) (eq (mod x 3) 0))))

(let* ((temp-observable ol)
       (where-op1 (rx:make-operator-where temp-observable
 				       #'(lambda (x) (evenp x))))
       (where-op2 (rx:make-operator-where where-op1
				       #'(lambda (x) (eq (mod x 3) 0))))
       (temp (rx:subscribe where-op2 observer)) )
  temp )
|#

#|
(macroexpand-1 '(rx:with-observable ol
  (rx:where (x) (evenp x))
  (rx:where (x) (eq (mod x 3) 0))
  (rx:subscribe observer)
  (rx:dispose) ))

 (rx:with-observable ol
  (rx:where (x) (evenp x))
  (rx:where (x) (eq (mod x 3) 0))
  (rx:subscribe observer)
  (rx:dispose) )
|#

#|
(with-observable observable
  (where (x) (evenp x))
  (where (x) (eq (mod x 3) 0))
  (subscribe observer) )


(let* ((temp-observable observable)
       (where-op1 (rx:make-operator-where temp-observable
 				       #'(lambda (x) (evenp x))))
       (where-op2 (rx:make-operator-where where-op1
				       #'(lambda (x) (eq (mod x 3) 0))))
       (temp (rx:subscribe where-op2 observer)) )
  temp )
|#
