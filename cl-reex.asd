#|
  This file is a part of cl-reex project.
|#

(defsystem "cl-reex"
  :version "0.1.0"
  :author "Jun Suzuki"
  :license "MIT"
  :depends-on ("bordeaux-threads")
  :components ((:module "src"
      :components
        ((:file "observable/observable")
         (:file "observer/observer")
         (:file "util/error-conditions")
         (:file "util/fixed-size-queue")
         (:file "macro/operator-table")
         (:file "operator/operator")
         (:file "operator/where")
         (:file "operator/select")
         (:file "operator/repeat")
         (:file "operator/take")
         (:file "operator/take-while")
         (:file "operator/take-until")
         (:file "operator/skip")
         (:file "operator/skip-while")
         (:file "operator/skip-until")
         (:file "operator/first")
         (:file "operator/last")
         (:file "operator/take-last")
         (:file "subject/subject")
         (:file "macro/with-observable")
         (:file "macro/handmade-observable")
         (:file "cl-reex"))))
  :description ""
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "cl-reex-test"))))
