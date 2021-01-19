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
        ((:file "observer/observer")
         (:file "observable/observable")
         (:file "observable/observable-amb")
         (:file "observable/observable-start")
         (:file "util/error-conditions")
         (:file "util/fixed-size-queue")
         (:file "macro/operator-table")
         (:file "subject/subject")
         (:file "subject/behavior-subject")
         (:file "subject/async-subject")
         (:file "subject/replay-subject")
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
         (:file "operator/skip-last")
         (:file "operator/ignore-elements")
         (:file "operator/distinct")
         (:file "operator/finally")
         (:file "operator/catch")
         (:file "operator/element-at")
         (:file "operator/do")
         (:file "operator/sum")
         (:file "operator/average")
         (:file "operator/max")
         (:file "operator/min")
         (:file "operator/count")
         (:file "operator/reduce")
         (:file "operator/scan")
         (:file "operator/concat")
         (:file "operator/amb")
         (:file "operator/all")
         (:file "operator/contains")
         (:file "operator/default-if-empty")
         (:file "macro/with-observable")
         (:file "macro/handmade-observable")
         (:file "cl-reex"))))
  :description ""
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "cl-reex-test"))))
