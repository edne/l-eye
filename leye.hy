#!/usr/bin/env hy

(import [hy.lex [tokenize]])
(import [cairo])


(defn read-code [file-name]
  (with [[f (open file-name)]]
    (.read f)))


(defmain [&rest args]
  (setv file-name
    (get args (if (cdr args)
                1 0)))
  (setv code
    (read-code file-name))

  (print code))
