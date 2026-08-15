#!/usr/bin/env -S sbcl --script
#||#

(defun convert-integer (x)
  (cond
    ((zerop (mod x 15)) "FizzBuzz")
    ((zerop (mod x 3))  "Fizz")
    ((zerop (mod x 5))  "Buzz")
    (t (princ-to-string x))))

(defun convert (x)
  (multiple-value-bind (n end) (parse-integer x :junk-allowed t)
    (if (and n (= end (length x)))
        (convert-integer n)
        x)))

(defun main ()
  (dolist (arg (cdr sb-ext:*posix-argv*))
    (format t "~a~%" (convert arg))))

;; If script, run main
(unless (and (boundp '*fizzbuzz-autorun*) (null (symbol-value '*fizzbuzz-autorun*)))
  (main))