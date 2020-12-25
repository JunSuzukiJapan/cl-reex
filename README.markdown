# Cl-Reex

Reactive extnsions for common lisp.

## Installation

Clone this repository to your ```ql:*local-project-directories*```

or use [Roswell](https://github.com/roswell/roswell):

```
$ ros install JunSuzukiJapan/cl-reex
```




```
(ql:quickload :cl-reex)
```

## Examples

subscribe example:

```
(defvar observer (rx:make-observer
	#'(lambda (x) (print x))
	#'(lambda (x) (format t "error: ~S" x))
	#'(lambda () (print "completed")) ))

(rx:subscribe (rx:observable-from '(1 2 3 4 5)) observer)
```


operator example:

```
(defvar observer (rx:make-observer
	#'(lambda (x) (print x))
	#'(lambda (x) (format t "error: ~S" x))
	#'(lambda () (print "completed")) ))

(rx:with-observable (rx:observable-from '(1 2 3 4 5 6 7 8 9 10))
   (rx:where (x) (evenp x))
   (rx:where (x) (eq (mod x 3) 0))
   (rx:subscribe observer) )

(rx:with-observable (rx:observable-from #(1 2 3 4 5))
  (rx:where (x) (oddp x))
  (rx:select (x) (* x 3))
  (rx:subscribe observer)
  (rx:dispose) )
```

