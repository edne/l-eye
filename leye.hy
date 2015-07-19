#!/usr/bin/env hy

(import [math [pi]])
(import [hy.lex [tokenize]])
(import [cairo])


(defn list? [l]
  (isinstance l list))


(defn get-size [tree]
  (if (list? tree)
    (if tree
      (+
         (get-size (car tree))
         (get-size (cdr tree)))
      0)
    1))


(defn draw-circle [cr r]
  (.arc cr 0 0 r 0 (* 2 pi))
  (.stroke cr))


(defn draw-atom [cr atom])


(defn draw-cell [cr cell]
  (draw-circle cr 1)
  (.translate cr 0.5 0)
  (.scale cr 0.5 0.5)

  (if (list? (car cell))
    (draw-cell cr (car cell))
    (draw-atom cr (car cell)))

  (when (cdr cell)
    (draw-cell cr (cdr cell))))


(defn draw [tree]
  (setv W 1000)
  (setv H 1000)

  (setv surface
    (cairo.ImageSurface cairo.FORMAT_ARGB32 W H))
  (setv cr (cairo.Context surface))

  (.scale cr W H)
  (.set-source-rgb cr 0 0 0)
  (.set_line_width cr 0.01)
  (.scale cr 0.5 0.5)
  (.translate cr 1 1)

  (draw-cell cr tree)

  (.write-to-png surface "out.png"))


(defmain [&rest args]
  (setv file-name
    (get args (if (cdr args)
                1 0)))
  (setv code
    (with [[f (open file-name)]]
    (.read f)))

  (setv tree
    (tokenize code))

  (draw tree))
