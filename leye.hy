#!/usr/bin/env hy

(import [hy.lex [tokenize]])
(import [cairo])


(defn get-size [tree]
  (if (isinstance tree list)
    (if tree
      (+
         (get-size (car tree))
         (get-size (cdr tree)))
      0)
    1))


(defmain [&rest args]
  (setv file-name
    (get args (if (cdr args)
                1 0)))
  (setv code
    (with [[f (open file-name)]]
    (.read f)))

  (setv tree
    (tokenize code)))
