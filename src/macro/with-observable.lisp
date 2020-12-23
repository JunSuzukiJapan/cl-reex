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


