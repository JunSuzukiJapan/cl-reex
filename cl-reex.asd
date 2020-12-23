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
		 (:file "operator/operator")
		 (:file "macro/with-observable")
		 (:file "cl-reex"))))
  :description ""
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "cl-reex-test"))))
