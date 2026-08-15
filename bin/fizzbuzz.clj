#!/usr/bin/env bb

;; FizzBuzz as an example of why function pattern matching is good and bad.
;;
;; - Order matters, sort of: cond checks top to bottom, so the 15 case
;;   must come before 3 or 5 - same pitfall as the Elixir/Erlang guards.
;; - No function-head pattern matching on values here; Clojure dispatches
;;   on argument *shape* (arity, destructuring), not on literal values or
;;   arithmetic conditions, so this stays a cond/case instead of clauses.
;; - Complex cases still have to go inside function bodies - same as always.

(defn convert-integer [x]
  (cond
    (zero? (mod x 15)) "FizzBuzz"
    (zero? (mod x 3))  "Fizz"
    (zero? (mod x 5))  "Buzz"
    :else              (str x)))

(defn convert [x]
  (if-let [n (parse-long x)]
    (convert-integer n)
    x))

(defn -main [& args]
  (println (clojure.string/join "\n" (map convert args))))

(apply -main *command-line-args*)