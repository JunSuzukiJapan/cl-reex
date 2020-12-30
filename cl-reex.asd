#|
  This file is a part of cl-reex project.
|#

(defsystem "cl-reex"
  :version "0.1.0"
  :author "Jun Suzuki"
  :license "MIT"
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "observable/observable")
		 (:file "observer/observer")
		 (:file "macro/operator-table")
		 (:file "macro/symbols")
		 (:file "operator/operator")
		 (:file "operator/where")
		 (:file "operator/select")
		 (:file "operator/repeat")
		 (:file "operator/take")
		 (:file "operator/skip")
		 (:file "subject/subject")
		 (:file "macro/with-observable")
		 (:file "cl-reex"))))
  :description ""
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "cl-reex-test"))))
